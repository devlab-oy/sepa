require 'nokogiri'
require 'base64'
require 'openssl'

def load(file)
  f = File.open(file)
  soap = Nokogiri::XML(f)
  f.close
  soap
end

def calculate_body_digest(xml_file)
  body = xml_file.xpath("//soapenv:Body", 'soapenv' => 'http://schemas.xmlsoap.org/soap/envelope/').first
  bodycanon = body.canonicalize
  sha1 = OpenSSL::Digest::SHA1.new
  digestbin = sha1.digest(bodycanon)
  Base64.encode64(digestbin)
end

puts calculate_body_digest(load('xml_templates/example_responses/soap_response.xml'))