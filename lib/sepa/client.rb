module Sepa
  class Client
    def initialize(params)
      check_params(params)
      # Initialize savon client with params and construct soap message
      wsdl = params.fetch(:wsdl)
      @client = Savon.client(wsdl: wsdl)
      @soap = SoapRequest.new(params).to_xml
      @command = params.fetch(:command)
    end

    # Call savon to make the soap request with the correct command and the
    # the constructed soap. The returned object will be a savon response.
    def send
      @client.call(@command, xml: @soap)
    end

    private

      def check_params(params)
        check_params_hash(params)
        check_private_key(params[:private_key])
        check_cert(params[:cert])
        check_wsdl(params[:wsdl])
        check_customer_id(params[:customer_id])
        check_env(params[:environment])
        check_status(params[:status])
      end

      def check_params_hash(params)
        unless params.respond_to?(:each_pair)
          fail ArgumentError, "You didn't provide a proper hash"
        end
      end

      def check_private_key(private_key)
        unless private_key.respond_to?(:sign)
          fail ArgumentError, "You didn't provide a proper private key"
        end
      end

      def check_cert(cert)
        unless cert.respond_to?(:check_private_key)
          fail ArgumentError, "You didn't provide a proper cert"
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
          fail ArgumentError, "You didn't provide a proper environment." \
            "Acceptable values are PRODUCTION or TEST."
        end
      end

      def check_status(status)
        unless ['NEW', 'DOWNLOADED', 'ALL'].include?(status)
          fail ArgumentError, "You didn't provide a proper status." \
            "Acceptable values are NEW, DOWNLOADED or ALL."
        end
      end
  end
end
