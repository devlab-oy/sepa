require 'savon'
require 'nokogiri'
require 'openssl'
require 'base64'

private_key = OpenSSL::PKey::RSA.new File.read 'keys/private.pem'
cert = OpenSSL::X509::Certificate.new File.read 'keys/cert.pem'

def load_soap_request
  f = File.open("xml_templates/get_user_info_soap_request.xml")
  soap_request = Nokogiri::XML(f)
  f.close
  return soap_request
end

def load_application_request_signature
  f = File.open("xml_templates/application_request_signature.xml")
  application_request_signature = Nokogiri::XML(f)
  f.close
  return application_request_signature
end

def process_application_request
  #Load the application request from template
  f = File.open("xml_templates/get_user_info_application_request.xml")
  application_request = Nokogiri::XML(f)
  f.close

  # Change the customer id of the application request to Nordea's testing ID
  customer_id = application_request.at_css "CustomerId"
  customer_id.content = "11111111"

  #Set the timestamp
  timestamp = application_request.at_css "Timestamp"
  timestamp.content = Time.now

  #Canonicalize the application request
  canon_application_request = application_request.canonicalize
  return canon_application_request
end

def sign_application_request(application_request, application_request_signature, private_key, cert)
  #Take digest from application request and set it to the signature
  digest = OpenSSL::Digest.new('sha1', application_request)
  signature_digest = application_request_signature.at_css "DigestValue"
  signature_digest.content = digest

  #Sign the digest with private key and base64 code it
  digest_sign = OpenSSL::Digest::SHA1.new
  signature = private_key.sign(digest_sign, digest.to_s)
  signature_base64 = Base64.encode64(signature)

  #Add the base64 coded signature to the signature element
  signature_signature = application_request_signature.at_css "SignatureValue"
  signature_signature.content = signature_base64

  #Format the certificate and add the it to the certificate element
  cert_formatted = cert.to_s.split('-----BEGIN CERTIFICATE-----')[1].split('-----END CERTIFICATE-----')[0].gsub(/\s+/, "")
  signature_certificate = application_request_signature.at_css "X509Certificate"
  signature_certificate.content = cert_formatted

  #Convert application request to XML and add the signature element to it
  application_request_xml  = Nokogiri::XML(application_request)
  software_id = application_request_xml.at_css "SoftwareId"
  software_id.add_next_sibling(application_request_signature.root)

  #Base64 code the whole application request
  application_request_base64 = Base64.encode64(application_request_xml)

  return application_request_base64
end
def send_soap(soap_request)
  client = Savon.client(wsdl: "wsdl/wsdl_nordea.xml", pretty_print_xml: true, ssl_version: :SSLv2, ssl_cert_file: "keys/ssl_key.pem")
  response = client.call(:get_user_info, xml: soap_request.to_xml)
end

sign_application_request(process_application_request, load_application_request_signature, private_key, cert)
