module Sepa
  class DanskeSoapRequest < SoapBuilder
    # Builds the Danske SOAP, holding methods needed only for Danske Services
    def initialize(params)
      @params = params
    end

    def get_soap
      find_correct_build(@params)
    end

    private

      def find_correct_build(params)
        command = params.fetch(:command)

        case command
        when :create_certificate
          build_danske_create_certificate_request(params)
        end
      end

      def build_danske_create_certificate_request(params)
        ar = get_application_request # From SoapBuilder (private)
        command = params.fetch(:command)
        sender_id = params.fetch(:customer_id)
        request_id = params.fetch(:request_id)
        environment = params.fetch(:environment)
        cert = params.fetch(:cert)

        public_key = extract_public_key(cert) # From SoapBuilder
        body = load_body_template(command) # From SoapBuilder

        set_body_contents(body, sender_id, request_id, environment)
        encrypted_request = encrypt_application_request(ar, cert, public_key)
        add_encrypted_request_to_soap(encrypted_request, body)
      end

      # Builds : Create Certificate
      # ------------------------------------------------------------------------
      def set_body_contents(body, sender_id, request_id, environment)
        set_node(body, 'pkif|SenderId', sender_id)
        set_node(body, 'pkif|CustomerId', sender_id)
        set_node(body, 'pkif|RequestId', request_id)
        set_node(body, 'pkif|Timestamp', Time.now.iso8601)
        set_node(body, 'pkif|InterfaceVersion', 1)
        set_node(body, 'pkif|Environment', environment)
      end

      def encrypt_application_request(ar, cert, public_key)
        # Format certificate if using PEM format
        #cert = cert.to_s
        #cert = cert.split('-----BEGIN CERTIFICATE-----')[1]
        #cert = cert.split('-----END CERTIFICATE-----')[0]
        #cert.gsub!(/\s+/, "")
        formatted_cert = Base64.encode64(cert.to_der)

        # puts "----- ApplicationRequest PRE encryption -----"
        ar = ar.canonicalize(
          mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,
          with_comments=false
        )
        # puts ar
        # puts "----- ApplicationRequest PRE encryption -----"

        # Encrypt ApplicationRequest and set key
        cipher = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC')
        cipher.encrypt
        # Option 1
        #key = SecureRandom.hex(16)
        key = cipher.random_key
        cipher.key = key
        # Option2
        #iv = cipher.random_iv
        #iv = SecureRandom.hex(16)
        #cipher.iv = iv

        output = cipher.update(ar)
        output << cipher.final

        #built_cipher = "02 | 45465519283985986 | 00 | #{key}"

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

      def add_encrypted_request_to_soap(encrypted_request, body)
        encrypted_request = Nokogiri::XML(encrypted_request.to_xml)
        encrypted_request = encrypted_request.at_css('xenc|EncryptedData')
        body.at_css('pkif|CreateCertificateIn').add_child(encrypted_request)

        body
      end
      # ------------------------------------------------------------------------
  end
end