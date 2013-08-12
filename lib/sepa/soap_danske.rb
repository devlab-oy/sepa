module Sepa
  module DanskeSoapRequest
    def find_correct_build(params)
      command = params.fetch(:command)

      case command
      when :create_certificate
        build_certificate_request(params)
      when :upload_file, :download_file, :get_user_info, :download_file_list
        build_danske_generic_request(params)
      when :get_bank_certificate
        build_get_bank_certificate_request(params)
      end
    end

    def encrypt_application_request(ar, cert)
      cert = OpenSSL::X509::Certificate.new(cert)

      formatted_cert = format_cert(cert)

      public_key = cert.public_key

      cipher = OpenSSL::Cipher.new('DES-EDE3-CBC')
      cipher.encrypt

      key = cipher.random_key
      iv = cipher.random_iv

      output = cipher.update(ar.to_xml)
      output << cipher.final
      output = iv + output

      encryptedkey = public_key.public_encrypt(key)

      ciphervalue1 = Base64.encode64(encryptedkey)
      ciphervalue1.gsub!(/\s+/, "")

      ciphervalue2 = Base64.encode64(output)
      ciphervalue2.gsub!(/\s+/, "")

      builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
        xml['xenc'].EncryptedData('xmlns:xenc' => "http://www.w3.org/2001/" \
                                  "04/xmlenc#",
        'Type' => "http://www.w3.org/2001/04/xmlenc#Element") {
          xml.EncryptionMethod('Algorithm' => "http://www.w3.org/2001" \
          "/04/xmlenc#tripledes-cbc") {
          }
          xml['dsig'].KeyInfo('xmlns:dsig' => "http://www.w3.org/2000/09" \
          "/xmldsig#"){
            xml['xenc'].EncryptedKey('Recipient' =>"name:DanskeBankCryptCERT") {
              xml.EncryptionMethod('Algorithm' => "http://www.w3.org/2001" \
                                   "/04/xmlenc#rsa-1_5")
              xml['dsig'].KeyInfo {
                xml.X509Data {
                  xml.X509Certificate formatted_cert
                }
              }
              xml['xenc'].CipherData{
                xml.CipherValue ciphervalue1
              }
            }
          }
          xml['xenc'].CipherData{
            xml.CipherValue ciphervalue2
          }
        }
      end

      builder
    end

    def set_request_body_contents(body, sender_id, request_id, lang, receiver_id)
      set_node(body, 'bxd|SenderId', sender_id)
      set_node(body, 'bxd|RequestId', request_id)
      set_node(body, 'bxd|Timestamp', Time.now.iso8601)
      set_node(body, 'bxd|Language', lang)
      set_node(body, 'bxd|UserAgent',"Sepa Transfer Library version " + VERSION)
      set_node(body, 'bxd|ReceiverId', receiver_id)
    end

    def add_encrypted_generic_request_to_soap(encrypted_request, body)
      encrypted_request = Nokogiri::XML(encrypted_request.to_xml)
      encrypted_request = encrypted_request.at_css('xenc|EncryptedData')
      encrypted_request = Base64.encode64(encrypted_request)
      body.at_css('bxd|ApplicationRequest').add_child(encrypted_request)

      body
    end

    def build_danske_generic_request(params)
      ar = Nokogiri::XML(@ar)
      command = params.fetch(:command)
      sender_id = params.fetch(:customer_id)
      request_id = params.fetch(:request_id)
      receiver_id = params.fetch(:target_id)
      lang = params.fetch(:language)
      cert = OpenSSL::X509::Certificate.new(params.fetch(:cert))
      private_key = params.fetch(:private_key)

      body = load_body_template(command)
      header = load_header_template(@template_path)

      set_request_body_contents(body, sender_id, request_id, lang, receiver_id)
      encrypted_request = encrypt_application_request(ar, cert)
      add_encrypted_generic_request_to_soap(encrypted_request, body)

      process_header(header,body,private_key,cert)
      add_body_to_header(header,body)
    end

    def build_certificate_request(params)
      ar = @ar
      command = params.fetch(:command)
      sender_id = params.fetch(:customer_id)
      request_id = params.fetch(:request_id)
      environment = params.fetch(:environment)
      cert = params.fetch(:cert)

      body = load_body_template(command)

      set_body_contents(body, sender_id, request_id, environment)
      encrypted_request = encrypt_application_request(ar, cert)
      add_encrypted_request_to_soap(encrypted_request, body)
    end

    def set_body_contents(body, sender_id, request_id, environment)
      set_node(body, 'pkif|SenderId', sender_id)
      set_node(body, 'pkif|CustomerId', sender_id)
      set_node(body, 'pkif|RequestId', request_id)
      set_node(body, 'pkif|Timestamp', Time.now.utc.iso8601)
      set_node(body, 'pkif|InterfaceVersion', 1)
      set_node(body, 'pkif|Environment', environment)
    end

    def add_encrypted_request_to_soap(encrypted_request, body)
      encrypted_request = Nokogiri::XML(encrypted_request.to_xml)
      encrypted_request = encrypted_request.root
      body.at_css('pkif|CreateCertificateIn').add_child(encrypted_request)

      body
    end

    def build_get_bank_certificate_request(params)
      ar = Base64.decode64 @ar
      command = params.fetch(:command)
      sender_id = params.fetch(:customer_id)
      request_id = params.fetch(:request_id)

      body = load_body_template(command)

      set_bank_certificate_body_contents(body, sender_id, request_id)
      add_bank_certificate_body_to_soap(ar, body)
    end

    def set_bank_certificate_body_contents(body, sender_id, request_id)
      set_node(body, 'pkif|SenderId', sender_id)
      set_node(body, 'pkif|CustomerId', sender_id)
      set_node(body, 'pkif|RequestId', request_id)
      set_node(body, 'pkif|Timestamp', Time.now.iso8601)
      set_node(body, 'pkif|InterfaceVersion', 1)
    end

    def add_bank_certificate_body_to_soap(ar, body)
      ar = Nokogiri::XML(ar)

      ar = ar.at_css('elem|GetBankCertificateRequest')
      body.at_css('pkif|GetBankCertificateIn').add_child(ar)

      body
    end
  end
end
