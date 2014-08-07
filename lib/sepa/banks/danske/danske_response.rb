module Sepa
  class DanskeResponse < Response

    validate :valid_get_bank_certificate_response
    validate :can_be_decrypted_with_given_key

    def application_response
      @application_response ||= decrypt_application_response
    end

    def bank_encryption_certificate
      return unless @command == :get_bank_certificate

      @bank_encryption_certificate ||= extract_cert(doc, 'BankEncryptionCert', DANSKE_PKI)
    end

    def bank_signing_certificate
      return unless @command == :get_bank_certificate

      @bank_signing_certificate ||= extract_cert(doc, 'BankSigningCert', DANSKE_PKI)
    end

    def bank_root_certificate
      return unless @command == :get_bank_certificate

      @bank_root_certificate ||= extract_cert(doc, 'BankRootCert', DANSKE_PKI)
    end

    def own_encryption_certificate
      return unless @command == :create_certificate

      @own_encryption_certificate ||= extract_cert(doc, 'EncryptionCert', DANSKE_PKI)
    end

    def own_signing_certificate
      return unless @command == :create_certificate

      @own_signing_certificate ||= extract_cert(doc, 'SigningCert', DANSKE_PKI)
    end

    def ca_certificate
      return unless @command == :create_certificate

      @ca_certificate ||= extract_cert(doc, 'CACert', DANSKE_PKI)
    end

    def certificate
      if [:get_bank_certificate, :create_certificate].include? @command
        @certificate ||= begin
          extract_cert(doc, 'X509Certificate', DSIG)
        end
      else
        super
      end
    end

    def response_code
      return super unless [:get_bank_certificate, :create_certificate].include? @command

      node = doc.at('xmlns|ReturnCode', xmlns: DANSKE_PKI)
      node.content if node
    end

    def certificate_is_trusted?
      return true if @command == :get_bank_certificate

      verify_certificate_against_root_certificate(certificate, DANSKE_ROOT_CERTIFICATE)
    end

    private

      def find_node_by_uri(uri)
        return super unless [:get_bank_certificate, :create_certificate].include? @command

        doc_without_signature = doc.dup
        doc_without_signature.at('xmlns|Signature', xmlns: DSIG).remove
        doc_without_signature.at("[xml|id='#{uri}']")
      end

      def decrypt_application_response
        key = decrypt_embedded_key

        encypted_data = encrypted_application_response
        .css('CipherValue', 'xmlns' => XMLENC)[1]
        .content

        encypted_data = decode encypted_data
        iv = encypted_data[0, 8]
        encypted_data = encypted_data[8, encypted_data.length]

        decipher = OpenSSL::Cipher.new('DES-EDE3-CBC')
        decipher.decrypt
        decipher.key = key
        decipher.iv = iv

        decipher.update(encypted_data) + decipher.final
      end

      def valid_get_bank_certificate_response
        return unless @command == :get_bank_certificate

        if doc.at('xmlns|PKIFactoryServiceFault', xmlns: DANSKE_PKIF)
          errors.add(:base, "Did not get a proper response when trying to get bank's certificates")
        end
      end

      def encrypted_application_response
        @encrypted_application_response ||= begin
          encrypted_application_response = extract_application_response(BXD)
          xml_doc encrypted_application_response
        end
      end

      def can_be_decrypted_with_given_key
        return if [:get_bank_certificate, :create_certificate].include? @command
        return unless encrypted_application_response.css('CipherValue', 'xmlns' => XMLENC)[0]

        unless decrypt_embedded_key
          errors.add(:encryption_private_key, DECRYPTION_ERROR_MESSAGE)
        end
      end

      def decrypt_embedded_key
        enc_key = encrypted_application_response.css('CipherValue', 'xmlns' => XMLENC)[0].content
        enc_key = decode enc_key
        @encryption_private_key.private_decrypt(enc_key)

      rescue OpenSSL::PKey::RSAError
        nil
      end

  end
end
