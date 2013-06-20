module Sepa
  class Client
    # Check that parameters are valid, initialize savon client with them and
    # construct soap message
    def initialize(params)
      check_params(params)
      wsdl = params.fetch(:wsdl)
      @client = Savon.client(wsdl: wsdl, log_level: :info)
      @command = params.fetch(:command)

      # To define which kind of a SOAP request to build
      case params[:bank]
      when :nordea
        if @command == :get_certificate
          @soap = CertRequest.new(params).to_xml
        elsif [:get_user_info,:download_file_list,:download_file,:upload_file].include?(@command)
          @soap = SoapRequest.new(params).to_xml
        end
      when :danske
        if @command == :create_certificate
          @soap = DanskeCertRequest.new(params).to_xml
        else
          fail ArgumentError, "Command not supported by #{params[:bank]}"
        end
      end
    end

    # Call savon to make the soap request with the correct command and the
    # the constructed soap. The returned object will be a savon response.
    def send
      @client.call(@command, xml: @soap)
    end

    private

      # Tries to validate the parameters or their presence.
      def check_params(params)
        # Universally for all
        check_params_hash(params)
        check_bank(params[:bank])
        check_env(params[:environment])
        check_wsdl(params[:wsdl])
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
          check_cert(params[:cert])
          check_request_id(params[:request_id])
          check_keygen_type(params[:key_generator_type])
          check_encryption_pkcs10(params[:encryption_cert_pkcs10])
          check_signing_pkcs10(params[:signing_cert_pkcs10])
          check_pin(params[:pin])
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
        # elsif !request_id # Should never go here
        #   fail ArgumentError, "You didn't provide a request id"
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

      def check_wsdl(wsdl)
        schema_file = File.expand_path('../../../lib/sepa/xml_schemas/wsdl.xml',
                                       __FILE__)
        xsd = Nokogiri::XML::Schema(File.read(schema_file))

        begin
          wsdl_file = File.read(wsdl)
        rescue
          fail ArgumentError, "You didn't provide a wsdl file or the path is" \
            "invalid"
        end

        wsdl = Nokogiri::XML(wsdl_file)

        unless xsd.valid?(wsdl)
          fail ArgumentError, "The wsdl file provided doesn't validate " \
            "against the wsdl schema and thus was rejected."
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
        unless ['FI', 'SE', 'EN', nil].include?(lang)
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
