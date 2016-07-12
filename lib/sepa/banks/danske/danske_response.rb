module Sepa
  # Handles Danske Bank specific {Response} functionality. Mainly decryption and certificate
  # specific stuff.
  class DanskeResponse < Response
    validate :valid_get_bank_certificate_response
    validate :can_be_decrypted_with_given_key

    # @return [String]
    # @see Response#application_response
    def application_response
      @application_response ||= decrypt_application_response
    end

    # Returns the bank's encryption certificate which is used to encrypt messages sent to the bank.
    # The certificate is only present in `:get_bank_certificate` responess.
    #
    # @return [OpenSSL::X509::Certificate] if {#command} is `:get_bank_certificate`
    # @return [nil] if command is any other
    def bank_encryption_certificate
      return unless @command == :get_bank_certificate

      @bank_encryption_certificate ||= extract_cert(doc, 'BankEncryptionCert', DANSKE_PKI)
    end

    # Returns the bank's signing certificate which is used by the bank to sign the responses. The
    # certificate is only present in `:get_bank_certificate` responses
    #
    # @return [OpenSSL::X509::Certificate] if {#command} is `:get_bank_certificate`
    # @return [nil] if {#command} is any other
    def bank_signing_certificate
      return unless @command == :get_bank_certificate

      @bank_signing_certificate ||= extract_cert(doc, 'BankSigningCert', DANSKE_PKI)
    end

    # Returns the bank's root certificate which is the certificate that is used to sign bank's other
    # certificates. Only present in `:get_bank_certificate` responses.
    #
    # @return [OpenSSL::X509::Certificate] if {#command} is `:get_bank_certificate`
    # @return [nil] if {#command} is any other
    def bank_root_certificate
      return unless @command == :get_bank_certificate

      @bank_root_certificate ||= extract_cert(doc, 'BankRootCert', DANSKE_PKI)
    end

    # Returns own encryption certificate which has been signed by the bank. Only present in
    # `:create_certificate` & `:renew_certificate` responses
    #
    # @return [OpenSSL::X509::Certificate] if {#command} is `:create_certificate` or `:renew_certificate`
    # @return [nil] if command is any other
    def own_encryption_certificate
      return unless [:create_certificate, :renew_certificate].include?(@command)

      @own_encryption_certificate ||= extract_cert(doc, 'EncryptionCert', DANSKE_PKI)
    end

    # Returns own signing certificate which has been signed by the bank. Is used to sign requests
    # sent to the bank. Is only present in `:create_certificate` & `:renew_certificate` responses.
    #
    # @return [OpenSSL::X509::Certificate] if {#command} is `:create_certificate` or `:renew_certificate`
    # @return [nil] if command is any other
    def own_signing_certificate
      return unless [:create_certificate, :renew_certificate].include?(@command)

      @own_signing_certificate ||= extract_cert(doc, 'SigningCert', DANSKE_PKI)
    end

    # Returns the CA certificate that has been used to sign own signing and encryption certificates.
    # Only present in `:create_certificate` & `:renew_certificate` responses
    #
    # @return [OpenSSL::X509::Certificate] if {#command} is `:create_certificate` or `:renew_certificate`
    # @return [nil] if command is any other
    def ca_certificate
      return unless [:create_certificate, :renew_certificate].include?(@command)

      @ca_certificate ||= extract_cert(doc, 'CACert', DANSKE_PKI)
    end

    # Extract certificate that has been used to sign the response. This overrides
    # {Response#certificate} method with specific functionality for `:get_bank_certificate`,
    # `:create_certificate` & `:renew_certificate` commands. Otherwise just calls {Response#certificate}
    #
    # @return [OpenSSL::X509::Certificate]
    # @raise [OpenSSL::X509::CertificateError] if certificate cannot be processed
    def certificate
      return super unless [:get_bank_certificate, :create_certificate, :renew_certificate].include? @command

      @certificate ||= extract_cert(doc, 'X509Certificate', DSIG)
    end

    # Extract response code from the response. Overrides super method when {#command} is
    # `:get_bank_certificate`, `:create_certificate` or `:renew_certificate` because response code node is named
    # differently in those responses.
    #
    # @return [String] if response code is found
    # @return [nil] if response code cannot be found
    # @see Response#response_code
    def response_code
      return super unless [:get_bank_certificate, :create_certificate, :renew_certificate].include? @command

      node = doc.at('xmlns|ReturnCode', xmlns: DANSKE_PKI)
      node = doc.at('xmlns|ReturnCode', xmlns: DANSKE_PKIF) unless node

      node.content if node
    end

    # Extract response text from the response. Overrides super method when {#command} is
    # `:get_bank_certificate`, `:create_certificate` or `:renew_certificate` because response text node is named
    # differently in those responses.
    #
    # @return [String] if response text is found
    # @return [nil] if response text cannot be found
    # @see Response#response_text
    def response_text
      return super unless [:get_bank_certificate, :create_certificate, :renew_certificate].include? @command

      node = doc.at('xmlns|ReturnText', xmlns: DANSKE_PKI)
      node = doc.at('xmlns|ReturnText', xmlns: DANSKE_PKIF) unless node

      node.content if node
    end

    # Checks whether certificate embedded in the response has been signed with the bank's root
    # certificate. Always returns true when {#command} is `:get_bank_certificate`, because the
    # certificate is not present with that command.
    #
    # @return [true] if certificate is trusted
    # @return [false] if certificate is not trusted
    def certificate_is_trusted?
      return true if @command == :get_bank_certificate

      verify_certificate_against_root_certificate(certificate, DANSKE_ROOT_CERTIFICATE)
    end

    private

      # Finds a node by its reference URI from Danske Bank's certificate responses. If {#command} is
      # other than `:get_bank_certificate`, `:create_certificate` or `:renew_certificate` returns super. This method is
      # needed because Danske Bank uses a different way to reference nodes in their certificate
      # responses.
      #
      # @param uri [String] reference URI of the node to find
      # @return [Nokogiri::XML::Node] node with signature removed from its document since signature
      #   has to be removed for canonicalization and hash calculation
      def find_node_by_uri(uri)
        return super unless [:get_bank_certificate, :create_certificate, :renew_certificate].include? @command

        doc_without_signature = doc.dup
        doc_without_signature.at('xmlns|Signature', xmlns: DSIG).remove
        doc_without_signature.at("[xml|id='#{uri}']")
      end

      # Decrypts the application response in the response. Starts by calling {#decrypt_embedded_key}
      # method to get the key used in encrypting the application response. After this the encrypted
      # data is retrieved from the document and base64 decoded. After this the iv
      # (initialization vector) is extracted from the encrypted data and a decipher with the
      # 'DES-EDE3-CBC' algorithm is initialized (This is used by banks as encryption algorithm) and
      # its key and iv set accordingly and mode changes to decrypt. After this the data is decrypted
      # and returned as string.
      #
      # @return [String] the decrypted application response as raw xml
      def decrypt_application_response
        key = decrypt_embedded_key

        encypted_data = encrypted_application_response
                        .css('CipherValue', 'xmlns' => XMLENC)[1]
                        .content

        encypted_data = decode encypted_data
        iv            = encypted_data[0, 8]
        encypted_data = encypted_data[8, encypted_data.length]

        decipher = OpenSSL::Cipher.new('DES-EDE3-CBC')
        decipher.decrypt
        decipher.key = key
        decipher.iv = iv

        decipher.update(encypted_data) + decipher.final
      end

      # Validates get bank certificate response. Response is valid if service fault is not returned
      # from the bank.
      def valid_get_bank_certificate_response
        return unless @command == :get_bank_certificate
        return unless doc.at('xmlns|PKIFactoryServiceFault', xmlns: DANSKE_PKIF)

        errors.add(:base, "Did not get a proper response when trying to get bank's certificates")
      end

      # Extracts the encrypted application response from the response and returns it as a nokogiri
      # document
      #
      # @return [Nokogiri::XML] the encrypted application response if it is found
      # @return [nil] if the application response cannot be found
      def encrypted_application_response
        @encrypted_application_response ||= begin
          encrypted_application_response = extract_application_response(BXD)
          xml_doc(encrypted_application_response)
        end
      end

      # Validates that the encrypted key in the response can be decrypted with the private key given
      # to the response in the parameters. Response is invalid if this cannot be done.
      def can_be_decrypted_with_given_key
        return if [:get_bank_certificate, :create_certificate, :renew_certificate].include? @command
        return unless encrypted_application_response.css('CipherValue', 'xmlns' => XMLENC)[0]
        return if decrypt_embedded_key

        errors.add(:encryption_private_key, DECRYPTION_ERROR_MESSAGE)
      end

      # Decrypts (assymetrically) the symmetric encryption key embedded in the response with the
      # private key given to the response in the parameters. The key is later used to decrypt the
      # application response.
      #
      # @return [String] the encryption key as a string
      # @return [nil] if the key cannot be decrypted with the given key
      def decrypt_embedded_key
        enc_key = encrypted_application_response.css('CipherValue', 'xmlns' => XMLENC)[0].content
        enc_key = decode enc_key
        @encryption_private_key.private_decrypt(enc_key)

      rescue OpenSSL::PKey::RSAError
        nil
      end
  end
end
