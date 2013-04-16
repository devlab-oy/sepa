require 'savon'
require 'nokogiri'
require 'openssl'

def get_user_info
    client = Savon.client(wsdl: "BankCorporateFileService_20080616.xml", pretty_print_xml: true)

    f = File.open("SOAPrequest_GetUserInfo.xml")
    doc = Nokogiri::XML(f)
    f.close

    binary_security_token = doc.xpath('wsse:BinarySecurityToken').first
    puts binary_security_token

    response = client.call(:get_user_info, xml: doc.to_s)
end

get_user_info
