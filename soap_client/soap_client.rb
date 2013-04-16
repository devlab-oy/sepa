require 'savon'
require 'nokogiri'
require 'openssl'

def send_soap
    client = Savon.client(wsdl: "BankCorporateFileService_20080616.xml", pretty_print_xml: true, ssl_version: :SSLv2, ssl_cert_file: "ssl_key.pem")

    f = File.open("SOAPrequest_GetUserInfo.xml")
    doc = Nokogiri::XML(f)
    f.close

    response = client.call(:get_user_info, xml: doc.to_s)
end

send_soap
