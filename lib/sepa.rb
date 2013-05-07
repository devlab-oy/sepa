require "sepa/version"
require "sepa/soap_request"

module Sepa
  class SepaClient
    def initialize(params)
      # Initialize savon client with params
      @client = Savon.client(wsdl: params[:wsdl], pretty_print_xml: true, log_level: :error)
      @soap = SoapRequest.new(params)
      @command = params[:command]
    end

    # Call savon to make the actual request to the server
    def send
      @client.call(@command, xml: @soap.to_xml)
    end
  end
end
