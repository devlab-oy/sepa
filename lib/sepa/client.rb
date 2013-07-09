module Sepa
  class Client
    # Check that parameters are valid, initialize savon client with them and
    # construct soap message
    def initialize(params)
      check_params(params)
      wsdl = params.fetch(:wsdl)
      @client = Savon.client(wsdl: wsdl)
      @command = params.fetch(:command)

      if @command == :get_certificate
        @soap = CertRequest.new(params).to_xml
      else
        @soap = SoapRequest.new(params).to_xml
      end
    end

    # Call savon to make the soap request with the correct command and the
    # the constructed soap. The returned object will be a savon response.
    def send
      @client.call(@command, xml: @soap)
    end

    private

      # Tries to validate the parameters as well as possible.
      def check_params(params)
        check_params_hash(params)

        if(params[:command] != :get_certificate)
          check_private_key(params[:private_key])
          check_cert(params[:cert])
          check_wsdl(params[:wsdl])
          check_customer_id(params[:customer_id])
          check_env(params[:environment])
          check_lang(params[:language])
        end

        if(params[:command] == :get_certificate)
          check_wsdl(params[:wsdl])
          check_customer_id(params[:customer_id])
          check_env(params[:environment])
          check_service(params[:service])
          check_hmac(params[:hmac])
          check_content(params[:content])
        end

        case params[:command]
        when :download_file, :download_file_list
          check_status(params[:status])
          check_target_id(params[:target_id])
          check_file_type(params[:file_type])
        when :upload_file
          check_target_id(params[:target_id])
          check_file_type(params[:file_type])
          check_content(params[:content])
        end
      end

      def check_params_hash(params)
        unless params.respond_to?(:each_pair)
          fail ArgumentError, "You didn't provide a proper hash"
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
        unless ['PRODUCTION', 'TEST'].include?(env)
          fail ArgumentError, "You didn't provide a proper environment. " \
            "Acceptable values are PRODUCTION or TEST."
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
