module Sepa
  module DanskeSoapRequest

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

    def encrypt_application_request
      encryption_cert = OpenSSL::X509::Certificate.new(@enc_cert)
      encryption_public_key = encryption_cert.public_key
      encryption_cert = format_cert(encryption_cert)
      encrypted_ar, key = encrypt_ar
      encrypted_key = encrypt_key(key, encryption_public_key)
      build_encrypted_ar(encryption_cert, encrypted_key, encrypted_ar)
    end

    # Encrypts a given symmetric encryption key with a public key and returns it in base64 encoded
    # format
    def encrypt_key(key, public_key)
      encrypted_key = public_key.public_encrypt(key)
      Base64.encode64(encrypted_key)
    end

    # Encrypts the application request and returns it in base64 encoded format.
    # Also returns the key needed to decrypt it
    def encrypt_ar
      cipher = OpenSSL::Cipher.new('DES-EDE3-CBC').encrypt

      key = cipher.random_key
      iv = cipher.random_iv

      encrypted_data = cipher.update(@ar.to_xml)
      encrypted_data << cipher.final
      encrypted_data = iv + encrypted_data
      encrypted_data = Base64.encode64(encrypted_data)

      return encrypted_data, key
    end

    def build_encrypted_ar(cert, encrypted_data, encrypted_key)
      ar = Nokogiri::XML File.open "#{AR_TEMPLATE_PATH}/encrypted_request.xml"
      set_node(ar, 'dsig|X509Certificate', cert)
      set_node(ar, 'dsig|KeyInfo xenc|CipherValue', encrypted_data)
      set_node(ar, 'xenc|EncryptedData > xenc|CipherData > xenc|CipherValue', encrypted_key)
      ar
    end

    def set_generic_request_contents
      set_node(@template, 'bxd|SenderId', @customer_id)
      set_node(@template, 'bxd|RequestId', request_id)
      set_node(@template, 'bxd|Timestamp', iso_time)
      set_node(@template, 'bxd|Language', @language)
      set_node(@template, 'bxd|UserAgent', "Sepa Transfer Library version " + VERSION)
      set_node(@template, 'bxd|ReceiverId', @target_id)
    end

    def set_create_cert_contents
      set_node(@template, 'pkif|SenderId', @customer_id)
      set_node(@template, 'pkif|CustomerId', @customer_id)
      set_node(@template, 'pkif|RequestId', request_id)
      set_node(@template, 'pkif|Timestamp', iso_time)
      set_node(@template, 'pkif|InterfaceVersion', 1)
      set_node(@template, 'pkif|Environment', @environment)
    end

    def set_bank_certificate_contents
      set_node(@template, 'pkif|SenderId', @customer_id)
      set_node(@template, 'pkif|CustomerId', @customer_id)
      set_node(@template, 'pkif|RequestId', request_id)
      set_node(@template, 'pkif|Timestamp', iso_time)
      set_node(@template, 'pkif|InterfaceVersion', 1)
    end

    def build_danske_generic_request
      set_generic_request_contents
      encrypted_request = encrypt_application_request
      add_encrypted_generic_request_to_soap(encrypted_request)

      process_header
      add_body_to_header
    end

    def build_certificate_request
      set_create_cert_contents
      encrypted_request = encrypt_application_request
      add_encrypted_request_to_soap(encrypted_request)
    end

    def build_get_bank_certificate_request
      set_bank_certificate_contents
      add_bank_certificate_body_to_soap
    end

    def add_encrypted_request_to_soap(encrypted_request)
      encrypted_request = Nokogiri::XML(encrypted_request.to_xml)
      encrypted_request = encrypted_request.root
      @template.at_css('pkif|CreateCertificateIn').add_child(encrypted_request)

      @template
    end

    def add_encrypted_generic_request_to_soap(encrypted_request)
      encrypted_request = Nokogiri::XML(encrypted_request.to_xml)
      encrypted_request = encrypted_request.root
      encrypted_request = Base64.encode64(encrypted_request.to_xml)
      @template.at_css('bxd|ApplicationRequest').add_child(encrypted_request)

      @template
    end

    def add_bank_certificate_body_to_soap
      ar = @ar.to_nokogiri

      ar = ar.at_css('elem|GetBankCertificateRequest')
      @template.at_css('pkif|GetBankCertificateIn').add_child(ar)

      @template
    end

    def request_id
      SecureRandom.hex(5)
    end

  end
end
