require "sepa/version"
require "sepa/soap_request"
require "savon"
require "base64"

module Sepa
  class SepaClient
    def initialize(params)
      # Initialize savon client with params
      @client = Savon.client(wsdl: params[:wsdl], pretty_print_xml: true)
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

    def get_ar_as_xml
      response = send.body
      command_out = (@command.to_s + "out").to_sym
      Base64.decode64(response[command_out][:application_response])
    end
  end
end
