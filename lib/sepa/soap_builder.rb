module Sepa
  class SoapBuilder
    # SoapBuilder builds a soap message and signs it when necessary and calls RequestBuilder
    def initialize(params)
      check_params(params)
      @params = params
      bank = params.fetch(:bank)

      @ar = ApplicationRequest.new(params).get_as_base64

      @request = find_correct_bank(bank)

      @template_path = File.expand_path('../xml_templates/soap/', __FILE__)
    end

    def to_xml
      # Returns a complete SOAP message in xml format
      @request.get_soap.to_xml
    end

    private

      def find_correct_bank(bank)
        case bank
        when :danske
          DanskeSoapRequest.new(@params)
        when :nordea
        else
          fail ArgumentError, "Bank not found"
        end
      end

      def get_application_request
        @ar
      end

      # def build_soap(params)
      #   case @type
      #   when "NordeaGetCertificateRequest"
      #     build_nordea_get_certificate_request(params)
      #   when "DanskeCreateCertificateRequest"
      #     build_danske_create_certificate_request(params)
      #   when "NordeaGenericRequest"
      #     build_nordea_generic_request(params)
      #   end
      # end

      # def find_correct_request_type(bank, command)
      #   # To define which kind of a SOAP request to build, Certificate Requests are always special cases
      #   # and very bank specific
      #   case bank
      #   when :nordea
      #     if command == :get_certificate
      #       "NordeaGetCertificateRequest"
      #     elsif [:get_user_info,:download_file_list,:download_file,:upload_file].include?(command)
      #       "NordeaGenericRequest"
      #     # else
      #     #   fail ArgumentError, "Command not supported by Nordea"
      #     end
      #   when :danske
      #     if command == :create_certificate
      #       "DanskeCreateCertificateRequest"
      #     else
      #       fail ArgumentError, "Command not supported by Danske"
      #     end
      #   end
      # end

      def build_nordea_get_certificate_request(params)
        command = params.fetch(:command)
        ar = @ar
        sender_id = params.fetch(:customer_id)

        body = load_body_template(command)
        nc_set_body_contents(body, ar, sender_id)
      end

      def build_nordea_generic_request(params)
        # Pick the needed params from the hash
        command = params.fetch(:command)
        ar = @ar #This is to be changed
        sender_id = params.fetch(:customer_id)
        lang = params.fetch(:language)
        receiver_id = params.fetch(:target_id)
        private_key = params.fetch(:private_key)
        cert = params.fetch(:cert)

        # From templates
        header = load_header_template(@template_path)
        body = load_body_template(command)

        ng_set_body_contents(body, ar, sender_id, lang, receiver_id)
        ng_process_header(header,body, private_key, cert)
        ng_add_body_to_header(header, body)
      end

      def build_danske_create_certificate_request(params)
        ar = @ar
        command = params.fetch(:command)
        sender_id = params.fetch(:customer_id)
        request_id = params.fetch(:request_id)
        environment = params.fetch(:environment)
        cert = params.fetch(:cert)

        public_key = extract_public_key(cert)
        body = load_body_template(command)

        dc_set_body_contents(body, sender_id, request_id, environment)
        encrypted_request = dc_encrypt_application_request(ar, cert, public_key)
        dc_add_request_to_soap(encrypted_request, body)
      end

      def build_danske_create_certificate_request_without_encryption(params)
        ar = @ar
        command = params.fetch(:command)
        sender_id = params.fetch(:customer_id)
        request_id = params.fetch(:request_id)
        environment = params.fetch(:environment)

        body = load_body_template(command)

        dc_set_body_contents(body, sender_id, request_id, environment)
        dc_add_unencrypted_request_to_soap(ar, body)
      end

      # Generic building steps
      def calculate_digest(doc, node)
        sha1 = OpenSSL::Digest::SHA1.new

        node = doc.at_css(node)

        canon_node = node.canonicalize(
          mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
          inclusive_namespaces=nil,with_comments=false
        )

        Base64.encode64(sha1.digest(canon_node)).gsub(/\s+/, "")
      end

      def calculate_signature(doc, node, private_key)
        sha1 = OpenSSL::Digest::SHA1.new

        node = doc.at_css(node)

        canon_signed_info_node = node.canonicalize(
          mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,
          with_comments=false
        )

        signature = private_key.sign(sha1, canon_signed_info_node)

        Base64.encode64(signature).gsub(/\s+/, "")
      end

      def load_body_template(command)
        case command
        when :download_file_list
          path = "#{@template_path}/download_file_list.xml"
        when :get_user_info
          path = "#{@template_path}/get_user_info.xml"
        when :upload_file
          path = "#{@template_path}/upload_file.xml"
        when :download_file
          path = "#{@template_path}/download_file.xml"
        when :create_certificate
          path = "#{@template_path}/create_certificate.xml"
        when :get_certificate
          path = "#{@template_path}/get_certificate.xml"
        end

        body_template = File.open(path)
        body = Nokogiri::XML(body_template)
        body_template.close

        body
      end

      def set_node(doc, node, value)
        doc.at_css(node).content = value
      end

      def extract_public_key(cert)
        pkey = cert.public_key
        pkey = OpenSSL::PKey::RSA.new(pkey)

        pkey
      end

      def format_cert(cert)
        cert = cert.to_s
        cert = cert.split('-----BEGIN CERTIFICATE-----')[1]
        cert = cert.split('-----END CERTIFICATE-----')[0]
        cert.gsub!(/\s+/, "")
      end

      def load_header_template(template_path)
        header_template = File.open("#{template_path}/header.xml")
        header = Nokogiri::XML(header_template)
        header_template.close
        header
      end

      # Building steps for Nordea Get Certificate

      def nc_set_body_contents(body, ar, sender_id)
        set_node(body, 'cer|ApplicationRequest', ar)
        set_node(body, 'cer|SenderId', sender_id)
        set_node(body, 'cer|RequestId', SecureRandom.hex(17))
        set_node(body, 'cer|Timestamp', Time.now.iso8601)

        body
      end
      # Building steps for Nordea Generic

      def ng_set_body_contents(body, ar, sender_id, lang, receiver_id)
        set_node(body, 'bxd|ApplicationRequest', ar)
        set_node(body, 'bxd|SenderId', sender_id)
        set_node(body, 'bxd|RequestId', SecureRandom.hex(17))
        set_node(body, 'bxd|Timestamp', Time.now.iso8601)
        set_node(body, 'bxd|Language', lang)
        set_node(body, 'bxd|UserAgent',
                 "Sepa Transfer Library version " + VERSION)
        set_node(body, 'bxd|ReceiverId', receiver_id)
      end

      def ng_process_header(header, body, private_key, cert)
        set_node(header, 'wsu|Created', Time.now.iso8601)

        set_node(header, 'wsu|Expires', (Time.now + 3600).iso8601)

        timestamp_digest = calculate_digest(header,'wsu|Timestamp')
        set_node(header,'dsig|Reference[URI="#dsfg8sdg87dsf678g6dsg6ds7fg"]' \
                 ' dsig|DigestValue', timestamp_digest)

        body_digest = calculate_digest(body, 'env|Body')
        set_node(header,'dsig|Reference[URI="#sdf6sa7d86f87s6df786sd87f6s8fsd'\
                 'a"] dsig|DigestValue', body_digest)

        signature = calculate_signature(header, 'dsig|SignedInfo', private_key)
        set_node(header, 'dsig|SignatureValue', signature)

        formatted_cert = format_cert(cert)
        set_node(header, 'wsse|BinarySecurityToken', formatted_cert)
      end

      def ng_add_body_to_header(header, body)
        body = body.at_css('env|Body')
        header.root.add_child(body)
        header
      end
      # Building steps for Danske Create Certificate

      # def dc_set_body_contents(body, sender_id, request_id, environment)
      #   set_node(body, 'pkif|SenderId', sender_id)
      #   set_node(body, 'pkif|CustomerId', sender_id)
      #   set_node(body, 'pkif|RequestId', request_id)
      #   set_node(body, 'pkif|Timestamp', Time.now.iso8601)
      #   set_node(body, 'pkif|InterfaceVersion', 1)
      #   set_node(body, 'pkif|Environment', environment)
      # end

      # def dc_add_request_to_soap(encrypted_request, body)
      #   encrypted_request = Nokogiri::XML(encrypted_request.to_xml)
      #   encrypted_request = encrypted_request.at_css('xenc|EncryptedData')
      #   body.at_css('pkif|CreateCertificateIn').add_child(encrypted_request)

      #   body
      # end

      # def dc_add_unencrypted_request_to_soap(ar, body)
      #   ar = Nokogiri::XML(ar.to_xml)
      #   ar = ar.at_css('tns|CreateCertificateRequest')
      #   body.at_css('pkif|CreateCertificateIn').add_child(ar)

      #   body
      # end

      # def dc_encrypt_application_request(ar, cert, public_key)
      #   # Format certificate if using PEM format
      #   #cert = cert.to_s
      #   #cert = cert.split('-----BEGIN CERTIFICATE-----')[1]
      #   #cert = cert.split('-----END CERTIFICATE-----')[0]
      #   #cert.gsub!(/\s+/, "")
      #   formatted_cert = Base64.encode64(cert.to_der)

      #   # puts "----- ApplicationRequest PRE encryption -----"
      #   ar = ar.canonicalize(
      #     mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,
      #     with_comments=false
      #   )
      #   # puts ar
      #   # puts "----- ApplicationRequest PRE encryption -----"

      #   # Encrypt ApplicationRequest and set key
      #   cipher = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC')
      #   cipher.encrypt
      #   # Option 1
      #   #key = SecureRandom.hex(16)
      #   key = cipher.random_key
      #   cipher.key = key
      #   # Option2
      #   #iv = cipher.random_iv
      #   #iv = SecureRandom.hex(16)
      #   #cipher.iv = iv

      #   output = cipher.update(ar)
      #   output << cipher.final

      #   #built_cipher = "02 | 45465519283985986 | 00 | #{key}"

      #   # Base64 encode and encrypt key and set as content for encrypted application request
      #   ciphervalue1 = Base64.encode64(public_key.public_encrypt(key))
      #   ciphervalue2 = Base64.encode64(output)

      #   # Build the xml to contain encrypted fields
      #   builder = Nokogiri::XML::Builder.new do |xml|
      #     xml['xenc'].EncryptedData('xmlns:xenc' => "http://www.w3.org/2001/04/xmlenc#", 'Type' => "http://www.w3.org/2001/04/xmlenc#Element") {
      #       xml.EncryptionMethod('Algorithm' => "http://www.w3.org/2001/04/xmlenc#tripledes-cbc") {
      #       }
      #       xml['dsig'].KeyInfo('xmlns:dsig' => "http://www.w3.org/2000/09/xmldsig#"){
      #          xml['xenc'].EncryptedKey('Recipient' =>"name:DanskeBankCryptCERT"){
      #               xml.EncryptionMethod('Algorithm' => "http://www.w3.org/2001/04/xmlenc#rsa-1_5")
      #               xml['dsig'].KeyInfo {
      #                    xml.X509Data {
      #                    xml.X509Certificate formatted_cert
      #                    }
      #               }
      #               xml['xenc'].CipherData{
      #                    xml.CipherValue ciphervalue1
      #               }
      #          }
      #       }
      #       xml['xenc'].CipherData{
      #                    xml.CipherValue ciphervalue2
      #               }
      #     }
      #   end

      # builder
      # end

      # Tries to validate the parameters or their presence.
      def check_params(params)
        # Universally for all
        check_params_hash(params)
        check_bank(params[:bank])
        check_env(params[:environment])
        check_customer_id(params[:customer_id])

        # Generic commands
        generic_commands = [:download_file,:download_file_list,:get_user_info]

        # Depending on command
        case params[:command]
        when :get_certificate
          check_service(params[:service])
          check_hmac(params[:hmac])
          check_content(params[:content])
        when *generic_commands
          if params[:bank] == :nordea
          check_private_key(params[:private_key])
          check_cert(params[:cert])
          check_lang(params[:language])
          check_status(params[:status])
          check_target_id(params[:target_id])
          check_file_type(params[:file_type])
          end
        when :upload_file
          check_private_key(params[:private_key])
          check_cert(params[:cert])
          check_lang(params[:language])
          check_target_id(params[:target_id])
          check_file_type(params[:file_type])
          check_content(params[:content])
        when :create_certificate
          if params[:bank] == :danske
          check_cert(params[:cert])
          check_request_id(params[:request_id])
          check_keygen_type(params[:key_generator_type])
          check_encryption_pkcs10(params[:encryption_cert_pkcs10])
          check_signing_pkcs10(params[:signing_cert_pkcs10])
          check_pin(params[:pin])
          end
        else
          fail ArgumentError, "Command not supported."
        end
      end

      def check_params_hash(params)
        unless params.respond_to?(:each_pair)
          fail ArgumentError, "You didn't provide a proper hash"
        end
      end

      def check_bank(bank)
          unless [:nordea, :danske].include?(bank)
          fail ArgumentError, "You didn't provide a proper bank. " \
            "Acceptable values are nordea OR danske."
        end
      end

      def check_request_id(request_id)
        if request_id.to_i == 0
          fail ArgumentError, "Request ID must be a number and not 0"
        end
      end

      def check_keygen_type(keygen)
        unless keygen
          fail ArgumentError, "You didn't provide any Key Generator Type"
        end
      end

      def check_encryption_pkcs10(enc_cert)
        unless enc_cert
          fail ArgumentError, "You didn't provide Encrypting certificate PKCS10"
        end
      end

      def check_signing_pkcs10(sig_cert)
        unless sig_cert
          fail ArgumentError, "You didn't provide Signing certificate PKCS10"
        end
      end

      def check_pin(pin)
        unless pin
          fail ArgumentError, "You didn't provide a secret PIN"
        end
      end

      def check_private_key(private_key)
        unless private_key.respond_to?(:sign)
          fail ArgumentError, "You didn't provide a proper private key. The " \
            "key has to be in OpenSSL::PKey::RSA - format."
        end
      end

      def check_cert(cert)
        unless cert.respond_to?(:check_private_key)
          fail ArgumentError, "You didn't provide a proper certificate. The " \
            "certificate has to be in OpenSSL::X509::Certificate - format."
        end
      end

      def check_customer_id(customer_id)
        unless customer_id && customer_id.respond_to?(:to_s) &&
            customer_id.length <= 16
          fail ArgumentError, "You didn't provide a proper customer id"
        end
      end

      def check_env(env)
        unless ['PRODUCTION', 'TEST', 'customertest'].include?(env)
          fail ArgumentError, "You didn't provide a proper environment. " \
            "Acceptable values are PRODUCTION or TEST or customertest."
        end
      end

      def check_status(status)
        unless ['NEW', 'DOWNLOADED', 'ALL'].include?(status)
          fail ArgumentError, "You didn't provide a proper status. " \
            "Acceptable values are NEW, DOWNLOADED or ALL."
        end
      end

      def check_target_id(target_id)
        unless target_id && target_id.respond_to?(:to_s) &&
            target_id.length <= 80
          fail ArgumentError, "You didn't provide a proper target id"
        end
      end

      def check_lang(lang)
        unless ['FI', 'SE', 'EN'].include?(lang)
          fail ArgumentError, "You didn't provide a proper language. " \
            "Acceptable values are FI, SE or EN."
        end
      end

      def check_file_type(file_type)
        unless file_type && file_type.respond_to?(:to_s) &&
            file_type.length <= 20
          fail ArgumentError, "You didn't provide a proper file type. Check " \
            "Your bank's documentation for available file types."
        end
      end

      def check_content(content)
        unless content
          fail ArgumentError, "You didn't provide any content."
        end
      end

      def check_service(service)
        unless ['service', 'ISSUER', 'MATU'].include?(service)
          fail ArgumentError, "You didn't provide a proper service."
        end
      end

      def check_hmac(hmac)
        unless hmac
          fail ArgumentError, "You didn't provide any HMAC."
        end
      end
  end
end
