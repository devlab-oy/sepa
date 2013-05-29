module Sepa
  class Client
    def initialize(params)
      # Initialize savon client with params
      @client = Savon.client(wsdl: params[:wsdl], pretty_print_xml: true, log_level: :warn)
      @soap = SoapRequest.new(params)
      @command = params[:command]
    end

    # Call savon to make the actual request to the server
    def send
      @client.call(@command, xml: @soap.to_xml)
    end

    def get_ar_as_base64
      response = send.body
      command_out = (@command.to_s + "out").to_sym
      response[command_out][:application_response]
    end

    def get_ar_as_string
      Base64.decode64(get_ar_as_base64)
    end

    def get_content_as_base64
      ar = Nokogiri::XML(get_ar_as_string)
      ar.remove_namespaces!
      (ar.at_css "Content").content
    end

    def get_content_as_string
      Base64.decode64(get_content_as_base64)
    end
  end
end