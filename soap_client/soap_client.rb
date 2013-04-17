require 'savon'
require 'nokogiri'
require 'openssl'

def get_user_info
    f = File.open("xml_templates/get_user_info_soap_request.xml")
    soap_request = Nokogiri::XML(f)
    f.close

    f = File.open("xml_templates/get_user_info_application_request.xml")
    application_request = Nokogiri::XML(f)
    f.close

    # Change the customer id of the application request to Nordea's testing ID
    customer_id = application_request.at_css "CustomerId"
    customer_id.content = "11111111"
    puts application_request

    client = Savon.client(wsdl: "wsdl/wsdl_nordea.xml", pretty_print_xml: true, ssl_version: :SSLv2, ssl_cert_file: "keys/ssl_key.pem")

    response = client.call(:get_user_info, xml: soap_request.to_xml)
end

get_user_info
