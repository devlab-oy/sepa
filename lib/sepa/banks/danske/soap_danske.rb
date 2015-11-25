module Sepa

  # Contains Danske Bank specific soap building functionality
  module DanskeSoapRequest

    private

      # Determines which kind of request to build depending on command. Certificate requests differ
      # from generic requests.
      #
      # @return [Nokogiri::XML] the built soap as a nokogiri document
      # @todo remove `:get_user_info` since Danske Bank doesn't support it
      def find_correct_build
        case @command
        when :create_certificate
          build_certificate_request
        when :upload_file, :download_file, :get_user_info, :download_file_list
          build_danske_generic_request
        when :get_bank_certificate
          build_get_bank_certificate_request
        end
      end

      # Encrypts the application request with the public key of the bank encryption certificate got
      # from the parameters. The actual encryption is done by {#encrypt_ar} and {#encrypt_key}
      # methods. After the encryption, the encrypted application request xml is built by
      # {#build_encrypted_ar} method
      #
      # @return [Nokogiri::XML] the encrypted application request as a nokogiri document
      def encrypt_application_request
        encryption_certificate = x509_certificate(@bank_encryption_certificate)
        encryption_public_key = encryption_certificate.public_key
        encryption_certificate = format_cert(encryption_certificate)
        encrypted_application_request, key = encrypt_ar
        encrypted_key = encrypt_key(key, encryption_public_key)
        build_encrypted_ar(encryption_certificate, encrypted_key, encrypted_application_request)
      end

      # Encrypts a given symmetric encryption key with a public key and returns it in base64 encoded
      # format.
      #
      # @param key [String] the key that will be encrypted
      # @param public_key [OpenSSL::PKey::RSA] the public key that will be used to do the encryption
      # @return [String] the encrypted key as a base64 encoded string
      # @todo make more generic and move to utilities
      def encrypt_key(key, public_key)
        encrypted_key = public_key.public_encrypt(key)
        encode encrypted_key
      end

      # Encrypts the application request and returns it in base64 encoded format. Also returns the
      # key needed to decrypt it. The encryption algorithm is 'DES-EDE3-CBC' and the iv is prepended
      # to the encrypted data.
      #
      # @return [Array(String, String)] the encrypted application request and the key needed to
      #   decrypt it
      def encrypt_ar
        cipher = OpenSSL::Cipher.new('DES-EDE3-CBC').encrypt

        key = cipher.random_key
        iv = cipher.random_iv

        encrypted_data = cipher.update(@application_request.to_xml)
        encrypted_data << cipher.final
        encrypted_data = iv + encrypted_data
        encrypted_data = encode encrypted_data

        return encrypted_data, key
      end

      # Builds the xml structure for the encrypted application request that can be base64 encoded
      # and embedded to the soap.
      #
      # @param cert [#to_s] the certificate which public key was used for the asymmetric encryption
      # @param encrypted_data [#to_s] the encrypted application request
      # @param encrypted_key [#to_s] the encrypted key that was used for the symmetric encryption
      # @return [Nokogiri::XML] the encrypted application request xml structure as a nokogiri
      #   document
      # @todo rename
      def build_encrypted_ar(cert, encrypted_data, encrypted_key)
        ar = Nokogiri::XML File.open "#{AR_TEMPLATE_PATH}/encrypted_request.xml"
        set_node(ar, 'dsig|X509Certificate', cert)
        set_node(ar, 'dsig|KeyInfo xenc|CipherValue', encrypted_data)
        set_node(ar, 'xenc|EncryptedData > xenc|CipherData > xenc|CipherValue', encrypted_key)
        ar
      end

      # Sets contents for create certificate requests.
      #
      # @todo rename
      def set_create_cert_contents
        set_node(@template, 'pkif|SenderId', @customer_id)
        set_node(@template, 'pkif|CustomerId', @customer_id)
        set_node(@template, 'pkif|RequestId', request_id)
        set_node(@template, 'pkif|Timestamp', iso_time)
        set_node(@template, 'pkif|InterfaceVersion', 1)
        set_node(@template, 'pkif|Environment', @environment)
      end

      # Sets contents for get bank certificate requests
      #
      # @todo rename
      def set_bank_certificate_contents
        set_node(@template, 'pkif|SenderId', @customer_id)
        set_node(@template, 'pkif|CustomerId', @customer_id)
        set_node(@template, 'pkif|RequestId', request_id)
        set_node(@template, 'pkif|Timestamp', iso_time)
        set_node(@template, 'pkif|InterfaceVersion', 1)
      end

      # Builds Danske Bank's generic request soap. The processing order is as follows:
      # 1. The contents of the soap are set
      # 2. The application request is encrypted
      # 3. The encrypted application request xml structure is embedded in the soap
      # 4. The header is processed
      # 5. The body is added to the header
      #
      # @return [Nokogiri::XML] the complete soap
      def build_danske_generic_request
        common_set_body_contents
        set_receiver_id
        encrypted_request = encrypt_application_request
        add_encrypted_generic_request_to_soap(encrypted_request)

        process_header
        add_body_to_header
      end

      # Builds Danske Bank's create certificate request soap. Environment is set to `:customertest`
      # if set to `:test`. This request is encrypted but not signed.
      #
      # @return [Nokogiri::XML] the complete soap
      # @todo rename
      def build_certificate_request
        @environment = :customertest if @environment == :test
        set_create_cert_contents
        encrypted_request = encrypt_application_request
        add_encrypted_request_to_soap(encrypted_request)
      end

      # Builds get bank certificate request soap. This request is neither signed nor encrypted.
      #
      # @return [Nokogiri::XML] the complete soap
      def build_get_bank_certificate_request
        set_bank_certificate_contents
        add_bank_certificate_body_to_soap
      end

      # Adds encrypted application request xml structure to the soap. This method is used when
      # building create certificate requests and the encrypted application request xml structure
      # will not be base64 encoded.
      #
      # @param encrypted_request [Nokogiri::XML] the encrypted application request xml structure
      # @return [Nokogiri::XML] the soap with the encrypted application request added to it
      def add_encrypted_request_to_soap(encrypted_request)
        encrypted_request = Nokogiri::XML(encrypted_request.to_xml)
        encrypted_request = encrypted_request.root
        @template.at_css('pkif|CreateCertificateIn').add_child(encrypted_request)

        @template
      end

      # Adds the encrypted application request xml structure to generic request soap.
      # The application request is base64 encoded before it is added to the soap.
      #
      # @param encrypted_request [Nokogiri::XML] the encrypted application request xml structure
      # @return [Nokogiri::XML] the soap with the encrypted application request added to it
      # @todo refactor possible unnecessary conversion away and rename
      def add_encrypted_generic_request_to_soap(encrypted_request)
        encrypted_request = Nokogiri::XML(encrypted_request.to_xml)
        encrypted_request = encrypted_request.root
        encrypted_request = encode encrypted_request.to_xml
        @template.at_css('bxd|ApplicationRequest').add_child(encrypted_request)

        @template
      end

      # Adds get bank certificate application request to the soap
      #
      # @return [Nokogiri::XML] the soap with the application request added to it
      def add_bank_certificate_body_to_soap
        ar = @application_request.to_nokogiri

        ar = ar.at_css('elem|GetBankCertificateRequest')
        @template.at_css('pkif|GetBankCertificateIn').add_child(ar)

        @template
      end

      # Generates a random 10-character request id for Danske Bank's requests.
      #
      # @return [String] 10-character hexnumeric request id
      def request_id
        SecureRandom.hex(5)
      end

      def set_receiver_id
        set_node(@template, 'bxd|ReceiverId', 'DABAFIHH')
      end

  end
end
