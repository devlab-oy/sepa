require "sepa/version"
require "sepa/soap_request"
require "savon"

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
  end
end
