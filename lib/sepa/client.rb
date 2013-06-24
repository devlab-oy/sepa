module Sepa
  class Client
    # Check that parameters are valid, initialize savon client with them and
    # construct soap message
    def initialize(params)
      check_params(params)
      wsdl = params.fetch(:wsdl)
      @client = Savon.client(wsdl: wsdl) #log_level: :info
      @command = params.fetch(:command)
      # SoapBuilder creates a complete SOAP message structure and returns it (.to_xml -format)
      @soap = SoapBuilder.new(params).to_xml
    end

    # Call savon to make the soap request with the correct command and the
    # the constructed soap. The returned object will be a savon response.
    def send
      @client.call(@command, xml: @soap)
    end

    private

      def check_params(params)
        check_params_hash(params)
        check_wsdl(params[:wsdl])
      end

      def check_params_hash(params)
        unless params.respond_to?(:each_pair)
          fail ArgumentError, "You didn't provide a proper hash"
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
  end
end
