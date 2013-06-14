module Sepa
  class DanskeCertRequest
    def initialize(params)
      @command = params.fetch(:command)
      @sender_id = params.fetch(:customer_id)
      @request_id = params.fetch(:request_id)
      @cert = params.fetch(:cert)
      @environment = params.fetch(:environment)
      #@private_key = params.fetch(:private_key)
      @public_key = params.fetch(:public_key)
      @ar = ApplicationRequest.new(params).get_as_base64

      template_path = File.expand_path('../xml_templates/soap/', __FILE__)

      @body = load_body_template(template_path, @command)

      @cipher

    end

    def to_xml
      construct(@body, @command, @ar, @sender_id, @request_id, @cert, @public_key, @environment).to_xml
    end

    private

      def construct(body, command, ar, sender_id, request_id, cert, public_key, environment)
        set_body_contents(body, sender_id, request_id, environment)
        encrypted_request = encrypt_application_request(ar, cert, public_key)
        add_request_to_soap(encrypted_request, body)
      end

      def load_body_template(template_path, command)
        case command
        when :create_certificate
          path = "#{template_path}/create_certificate.xml"
        else
          fail LoadError, "Could not load soap request template because the" \
            "command was unrecognised"
        end

        body_template = File.open(path)
        body = Nokogiri::XML(body_template)
        body_template.close

        body
      end

      def load_encrypted_request_template(template_path, command)
        case command
        when :create_certificate
          path = "#{template_path}/danske_encrypted_request.xml"
        else
          fail LoadError, "Could not load soap request template because the" \
            "command was unrecognised"
        end

        encrypted_request_template = File.open(path)
        encrypted_request = Nokogiri::XML(encrypted_request_template)
        encrypted_request_template.close

        encrypted_request
      end

      def set_body_contents(body, sender_id, request_id, environment)
        set_node(body, 'pkif|SenderId', sender_id)
        set_node(body, 'pkif|CustomerId', sender_id)
        set_node(body, 'pkif|RequestId', request_id)
        set_node(body, 'pkif|Timestamp', Time.now.iso8601)
        set_node(body, 'pkif|InterfaceVersion', 1)
        set_node(body, 'pkif|Environment', environment)
      end

      def set_node(doc, node, value)
        doc.at_css(node).content = value
      end

      def add_request_to_soap(encrypted_request, body)
        encrypted_request = Nokogiri::XML(encrypted_request.to_xml)
        encrypted_request = encrypted_request.at_css('xenc|EncryptedData')
        body.at_css('pkif|CreateCertificateIn').add_child(encrypted_request)
        body
      end

      def encrypt_application_request(ar, cert, public_key)
        # Format certificate
        cert = cert.to_s
        cert = cert.split('-----BEGIN CERTIFICATE-----')[1]
        cert = cert.split('-----END CERTIFICATE-----')[0]
        cert.gsub!(/\s+/, "")
        formatted_cert = Base64.encode64(cert)

        # Encrypt ApplicationRequest and set key
        cipher = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC')
        cipher.encrypt
        key = cipher.random_iv
        cipher.iv = key
        output = cipher.update(ar)
        output << cipher.final

        # Base64 encode and encrypt key and set as content for encrypted application request
        ciphervalue1 = Base64.encode64(public_key.public_encrypt(key))
        ciphervalue2 = Base64.encode64(output)

        # Build the xml to contain encrypted fields
        builder = Nokogiri::XML::Builder.new do |xml|
          xml['xenc'].EncryptedData('xmlns:xenc' => "http://www.w3.org/2001/04/xmlenc#", 'Type' => "http://www.w3.org/2001/04/xmlenc#Element") {
            xml.EncryptionMethod('Algorithm' => "http://www.w3.org/2001/04/xmlenc#tripledes-cbc") {
            }
            xml['dsig'].KeyInfo('xmlns:dsig' => "http://www.w3.org/2000/09/xmldsig#"){
               xml['xenc'].EncryptedKey('Recipient' =>"name:DanskeBankCryptCERT"){
                    xml.EncryptionMethod('Algorithm' => "http://www.w3.org/2001/04/xmlenc#rsa-1_5")
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
  end
end
