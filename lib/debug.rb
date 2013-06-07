require 'savon'
require 'nokogiri'

params = {
  wsdl: 'sepa/wsdl/wsdl_nordea_cert.xml'
}

soap = Nokogiri::XML(File.open("mutant.xml"))

apprequest = Nokogiri::XML(File.open("certest/built_re.xml"))


ar_node = soap.xpath(".//cer:ApplicationRequest", 'cer' => 'http://bxd.fi/CertificateService').first
ar_node.content = Base64.encode64(apprequest.to_xml)

client = Savon.client(wsdl: params[:wsdl], pretty_print_xml: true)

client.call(:get_certificate, xml: soap.to_xml)