require 'savon'
require 'nokogiri'
require 'openssl'
require 'base64'

private_key = OpenSSL::PKey::RSA.new File.read 'keys/nordea.key'
cert = OpenSSL::X509::Certificate.new File.read 'keys/nordea.crt'

def load_soap_request
  f = File.open("xml_templates/soap/download_file_list.xml")
  soap_request = Nokogiri::XML(f)
  f.close
  soap_request
end

def load_soap_request_header
  f = File.open("xml_templates/soap/header.xml")
  soap_request_header = Nokogiri::XML(f)
  f.close
  soap_request_header
end

def process_application_request
  # Load the application request from template
  f = File.open("xml_templates/application_request/download_file_list.xml")
  application_request = Nokogiri::XML(f)
  f.close

  # Change the customer id of the application request to Nordea's testing ID
  customer_id = application_request.at_css "CustomerId"
  customer_id.content = "11111111"

  # Set the command
  command = application_request.at_css "Command"
  command.content = "DownloadFileList"

  #Set the timestamp
  timestamp = application_request.at_css "Timestamp"
  timestamp.content = Time.now.to_time.iso8601

  # Set status
  status = application_request.at_css "Status"
  status.content = "NEW"

  # Set the environment
  environment = application_request.at_css "Environment"
  environment.content = "PRODUCTION"

  # Set the target id
  targetid = application_request.at_css "TargetId"
  targetid.content = "11111111A1"

  # Set compression
  compression = application_request.at_css "Compression"
  compression.content = "false"

  #Set the software id
  softwareid = application_request.at_css "SoftwareId"
  softwareid.content = "Sepa Transfer Library version 0.1"

  # Set the file type
  filetype = application_request.at_css "FileType"
  filetype.content = "HTMKTO"

  # Save file for xmlsec
  File.open('xml_templates/application_request/download_file_list_processed.xml', 'w') { |file| file.write(application_request) }

  # Use xmlsec for signing
  system('xmlsec1 --sign --output xml_templates/application_request/download_file_list_signed.xml --pkcs12 keys/nordea.p12 --pwd WSNDEA1234 xml_templates/application_request/download_file_list_processed.xml')

  # Load the file again
  f = File.open("xml_templates/application_request/download_file_list_signed.xml")
  application_request = Nokogiri::XML(f)
  f.close

  # Remove second certificate
  second_cert = application_request.xpath("//dsig:X509Certificate[1]", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
  second_cert.remove

  Base64.encode64(application_request.to_xml)
end

def process_soap_request(soap_request, application_request_base64)
  #Add the base64 coded application request to the soap envelope after removing whitespaces
  soap_request_application_request = soap_request.xpath("//bxd:ApplicationRequest", 'bxd' => 'http://model.bxd.fi').first
  soap_request_application_request.content = application_request_base64.gsub(/\s+/, "")

  #Add the testing sender id
  soap_request_sender_id = soap_request.xpath("//bxd:SenderId", 'bxd' => 'http://model.bxd.fi').first
  soap_request_sender_id.content = "11111111"

  #Add request id
  soap_request_request_id = soap_request.xpath("//bxd:RequestId", 'bxd' => 'http://model.bxd.fi').first
  soap_request_request_id.content = "298374982374982374"

  #Add timestamp
  soap_request_timestamp = soap_request.xpath("//bxd:Timestamp", 'bxd' => 'http://model.bxd.fi').first
  soap_request_timestamp.content = Time.now.iso8601

  # Add language
  soap_request_language = soap_request.xpath("//bxd:Language", 'bxd' => 'http://model.bxd.fi').first
  soap_request_language.content = "FI"

  #Add useragent
  soap_request_useragent = soap_request.xpath("//bxd:UserAgent", 'bxd' => 'http://model.bxd.fi').first
  soap_request_useragent.content = "Sepa Transfer Library version 0.1"

  #Add receiver id
  soap_request_receiverid = soap_request.xpath("//bxd:ReceiverId", 'bxd' => 'http://model.bxd.fi').first
  soap_request_receiverid.content = "11111111A1"

  soap_request
end

def sign_soap_request(soap_request, soap_request_header, private_key, cert)
  #Add header timestamps
  created = soap_request_header.xpath("//wsu:Created", 'wsu' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd').first
  created.content = Time.now.iso8601
  expires = soap_request_header.xpath("//wsu:Expires", 'wsu' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd').first
  expires.content = (Time.now + 3600).iso8601

  # Take digest from header timestamps
  timestamp = soap_request_header.xpath("//wsu:Timestamp", 'wsu' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd').first
  sha1 = OpenSSL::Digest::SHA1.new
  digestbin = sha1.digest(timestamp.canonicalize(mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,with_comments=false))
  digest = Base64.encode64(digestbin)
  timestamp_digest = soap_request_header.xpath("//dsig:Reference[@URI='#dsfg8sdg87dsf678g6dsg6ds7fg']/dsig:DigestValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
  timestamp_digest.content = digest.gsub(/\s+/, "")

  #Take digest from soap request body, base64 code it and put it to the signature
  body = soap_request.xpath("//env:Body", 'env' => 'http://schemas.xmlsoap.org/soap/envelope/').first
  canonbody = body.canonicalize(mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,with_comments=false)
  sha1 = OpenSSL::Digest::SHA1.new
  digestbin = sha1.digest(canonbody)
  digest = Base64.encode64(digestbin)
  signature_digest = soap_request_header.xpath("//dsig:Reference[@URI='#sdf6sa7d86f87s6df786sd87f6s8fsda']/dsig:DigestValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
  signature_digest.content = digest.gsub(/\s+/, "")

  #Sign SignedInfo element with private key and add it to the correct field
  signed_info = soap_request_header.xpath("//dsig:SignedInfo", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
  canon_signed_info = signed_info.canonicalize(mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,with_comments=false)
  digest_sign = OpenSSL::Digest::SHA1.new
  signature = private_key.sign(digest_sign, canon_signed_info)
  signature_base64 = Base64.encode64(signature).gsub(/\s+/, "")

  #Add the base64 coded signature to the signature element
  signature_signature = soap_request_header.xpath("//dsig:SignatureValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
  signature_signature.content = signature_base64

  #Format the certificate and add the it to the certificate element
  cert_formatted = cert.to_s.split('-----BEGIN CERTIFICATE-----')[1].split('-----END CERTIFICATE-----')[0].gsub(/\s+/, "")
  signature_certificate = soap_request_header.xpath("//wsse:BinarySecurityToken", 'wsse' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd').first
  signature_certificate.content = cert_formatted

  soap_request_header.root.add_child(soap_request.xpath("//env:Body", 'env' => 'http://schemas.xmlsoap.org/soap/envelope/').first)

  soap_request_header
end

signed_application_request = process_application_request

soap_request = process_soap_request(load_soap_request, signed_application_request)

signed_soap_request = sign_soap_request(soap_request, load_soap_request_header, private_key, cert)

client = Savon.client(wsdl: "wsdl/wsdl_nordea.xml", pretty_print_xml: true)

response = client.call(:download_file_list, xml: signed_soap_request.to_xml)
