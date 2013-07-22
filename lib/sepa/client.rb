module Sepa
  class Client
    # Check that parameters are valid, initialize savon client with them and
    # construct soap message
    def initialize(params)
      check_params_hash(params)
      check_bank(params.fetch(:bank))
      bank = params.fetch(:bank)
      #command = check_command(params.fetch(:command))
      wsdl = find_proper_wsdl(bank, params.fetch(:command))

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

      def check_bank(bank)
          unless [:nordea, :danske].include?(bank)
          fail ArgumentError, "You didn't provide a proper bank. " \
            "Acceptable values are nordea OR danske."
        end
      end

      def find_proper_wsdl(bank, command)
        wsdlpath = File.expand_path('../../../lib/sepa/wsdl', __FILE__)
        case bank
        when :nordea
          if command == :get_certificate
            path = "#{wsdlpath}/wsdl_nordea_cert.xml"
          else
            path = "#{wsdlpath}/wsdl_nordea.xml"
          end
        when :danske
          if command == :create_certificate || command == :get_bank_certificate
            path = "#{wsdlpath}/wsdl_danske_cert.xml"
          else
            path = "#{wsdlpath}/wsdl_danske.xml"
          end
        end
        check_wsdl(path)
        path
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
          fail ArgumentError, "You didn't provide a wsdl file or the path is " \
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
