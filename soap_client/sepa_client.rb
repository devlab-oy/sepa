require 'savon'
require_relative 'soap_request'

class SepaClient
  def initialize(params)
    @client = Savon.client(wsdl: params[:wsdl], pretty_print_xml: true)
    @soap = SoapRequest.new(params)
    @command = params[:command]
  end

  def send
    @client.call(@command, xml: @soap.to_xml)
  end
end