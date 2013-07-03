module Sepa
  class SoapBuilder
    # SoapBuilder checks and validates incoming params and creates the SOAP structure
    def initialize(params)

      check_params(params)
      # Check if bank+command need keys/certificates/csr's and prepare them for use
      params = initialize_certificates_and_csr(params)
      @params = params

      check_if_bank_allows_command(params)

      @ar = ApplicationRequest.new(params).get_as_base64

      @bank = params.fetch(:bank)
      find_correct_bank_extension(@bank)

      @template_path = File.expand_path('../xml_templates/soap/', __FILE__)
    end

    def to_xml
      # Returns a complete SOAP message in xml format
      find_correct_build(@params).to_xml
    end

    def get_ar_as_base64
      @ar
    end

    # def get_ar_as_unencoded
    #   Base64.decode64 @ar
    # end

    private

      def find_correct_bank_extension(bank)
        case bank
        when :danske
          self.extend(DanskeSoapRequest)
        when :nordea
          self.extend(NordeaSoapRequest)
        end
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
        when :get_bank_certificate
          path = "#{@template_path}/danske_get_bank_certificate.xml"
        end

        body_template = File.open(path)
        body = Nokogiri::XML(body_template)
        body_template.close

        body
      end

      def set_node(doc, node, value)
        doc.at_css(node).content = value
      end

      def add_body_to_header(header, body)
        body = body.at_css('env|Body')
        header.root.add_child(body)
        header
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

      def process_header(header, body, private_key, cert)
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

      # Tries to validate the parameters or their presence.
      def check_params(params)
        # Universally for all
        check_params_hash(params)
        check_certificate_and_key_requirements(params)
        check_bank(params[:bank])
        check_env(params[:environment])
        check_customer_id(params[:customer_id])

        # Generic commands
        generic_commands = [:download_file,:download_file_list,:get_user_info]

        # Depending on command
        case params[:command]
        when :get_certificate
          check_pin(params[:pin])
          check_service(params[:service])
        when *generic_commands
          if params[:bank] == :nordea
          check_lang(params[:language])
          check_status(params[:status])
          check_target_id(params[:target_id])
          check_file_type(params[:file_type])
          end
        when :upload_file
          check_lang(params[:language])
          check_target_id(params[:target_id])
          check_file_type(params[:file_type])
          check_content(params[:content])
        when :create_certificate
          if params[:bank] == :danske
            check_keygen_type(params[:key_generator_type])
            check_pin(params[:pin])
          end
        when :get_bank_certificate
          if params[:bank] == :danske
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

      def check_if_bank_allows_command(params)
        bank = params.fetch(:bank)
        command = params.fetch(:command)
        case bank
        when :nordea
          allowed_commands = [:get_certificate,:get_user_info,:download_file_list,:download_file,:upload_file]
          unless allowed_commands.include?(command)
            fail ArgumentError, "You didn't provide a matching bank and service."
          end
        when :danske
          allowed_commands = [:get_bank_certificate,:create_certificate,:get_user_info,:download_file_list,:download_file,:upload_file]
          unless allowed_commands.include?(command)
            fail ArgumentError, "You didn't provide a matching bank and service."
          end
        end
      end

      def check_certificate_and_key_requirements(params)
        command = params[:command]
        require_private_and_cert = [:get_user_info,:download_file_list,:download_file,:upload_file]
        require_nothing = [:get_bank_certificate]
        require_pkcs = [:get_certificate]
        require_dual_pkcs_and_cert = [:create_certificate]

        case command
        when *require_private_and_cert
          if params[:cert_path] == nil && params[:cert_plain] == nil
            fail ArgumentError, "You must provide a path to the certificate or certificate in plain text"
          end
          if params[:private_key_path] == nil && params[:private_key_plain] == nil
            fail ArgumentError, "You must provide a path to your private key or private key in plain text"
          end
        when *require_nothing
        when *require_pkcs
          if params[:csr_path] == nil && params[:csr_plain] == nil
            fail ArgumentError, "You must provide a path to the CSR or CSR in plain text"
          end
        when *require_dual_pkcs_and_cert
          if params[:encryption_cert_pkcs10_path] == nil && params[:encryption_cert_pkcs10_plain] == nil
            fail ArgumentError, "You must provide a path to Encryption CSR or Encryption CSR in plain text"
          end
          if params[:signing_cert_pkcs10_path] == nil && params[:signing_cert_pkcs10_plain] == nil
            fail ArgumentError, "You must provide a path to Signing CSR or Signing CSR in plain text"
          end
          if params[:cert_path] == nil && params[:cert_plain] == nil
            fail ArgumentError, "You must provide a path to the certificate or certificate in plain text"
          end
        end
      end

      def initialize_certificates_and_csr(params)
        command = params[:command]
        require_private_and_cert = [:get_user_info,:download_file_list,:download_file,:upload_file]
        require_nothing = [:get_bank_certificate]
        require_pkcs = [:get_certificate]
        require_dual_pkcs_and_cert = [:create_certificate]
        case command
        when *require_private_and_cert
          if params[:cert_path] != nil
            params[:cert] = OpenSSL::X509::Certificate.new(File.read(params.fetch(:cert_path)))
          elsif params[:cert_plain] != nil
            params[:cert] = OpenSSL::X509::Certificate.new(params.fetch(:cert_plain))
          end
          if params[:private_key_path] != nil
             params[:private_key] = OpenSSL::PKey::RSA.new(File.read(params.fetch(:private_key_path)))
          elsif params[:private_key_plain] != nil
            params[:private_key] = OpenSSL::PKey::RSA.new(params.fetch(:private_key_plain))
          end
          check_private_key(params[:private_key])
          check_cert(params[:cert])
        when *require_nothing
        when *require_pkcs
          if params[:csr_path] != nil
            params[:csr] = OpenSSL::X509::Request.new(File.read(params.fetch(:csr_path)))
          elsif params[:csr_plain] != nil
            params[:csr] = OpenSSL::X509::Request.new(params.fetch(:csr_plain))
          end
        when *require_dual_pkcs_and_cert
          if params[:encryption_cert_pkcs10_path] != nil && params[:signing_cert_pkcs10_path] != nil
            params[:encryption_cert_pkcs10] = OpenSSL::X509::Request.new(File.read(params.fetch(:encryption_cert_pkcs10_path)))
            params[:signing_cert_pkcs10] = OpenSSL::X509::Request.new(File.read(params.fetch(:signing_cert_pkcs10_path)))
          elsif params[:encryption_cert_pkcs10_plain] != nil && params[:signing_cert_pkcs10_plain] != nil
            params[:encryption_cert_pkcs10] = OpenSSL::X509::Request.new(params.fetch(:encryption_cert_pkcs10_plain))
            params[:signing_cert_pkcs10] = OpenSSL::X509::Request.new(params.fetch(:signing_cert_pkcs10_plain))
          end
          if params[:cert_path] != nil
            params[:cert] = OpenSSL::X509::Certificate.new(File.read(params.fetch(:cert_path)))
          elsif params[:cert_plain] != nil
            params[:cert] = OpenSSL::X509::Certificate.new(params.fetch(:cert_plain))
          end

          check_encryption_pkcs10(params[:encryption_cert_pkcs10])
          check_signing_pkcs10(params[:signing_cert_pkcs10])
          check_cert(params[:cert])
        else
          fail ArgumentError, "No matching cases for initialize_certificates_and_csr"
        end
        params
      end
  end
end
