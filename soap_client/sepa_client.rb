require 'savon'
require_relative 'soap_request'
require_relative 'application_request'

class SepaClient
  def initialize(wsdl, soap)
    @client = Savon.client(wsdl: wsdl, pretty_print_xml: true)
    @soap = soap
  end

  def send
    @client.call(:download_file_list, xml: @soap.to_xml)
  end
end