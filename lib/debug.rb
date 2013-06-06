require 'savon'
require 'nokogiri'

params = {
  wsdl: 'sepa/wsdl/wsdl_nordea_cert.xml'
}

soap = Nokogiri::XML(File.open("mutant.xml"))

client = Savon.client(wsdl: params[:wsdl], pretty_print_xml: true)

client.call(:get_certificate, xml: soap.to_xml)