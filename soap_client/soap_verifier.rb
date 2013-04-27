require 'nokogiri'
require 'openssl'
require 'base64'

f = File.open("xml_templates/example_responses/soap_response.xml")
response = Nokogiri::XML(f)
f.close

body = response.xpath("//soapenv:Body", 'soapenv' => 'http://schemas.xmlsoap.org/soap/envelope/')

sha1 = OpenSSL::Digest::SHA1.new
digestbin = sha1.digest(body.to_s)
digest = Base64.encode64(digestbin)

puts digest