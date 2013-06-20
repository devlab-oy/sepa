# module Sepa
#   class DanskeCertRequest
#     def initialize(params)
#       @command = params.fetch(:command)
#       @sender_id = params.fetch(:customer_id)
#       @request_id = params.fetch(:request_id)
#       @cert = params.fetch(:cert)
#       @environment = params.fetch(:environment)
#       @ar = ApplicationRequest.new(params).get_as_base64

#       @public_key = extract_public_key(@cert)

#       template_path = File.expand_path('../xml_templates/soap/', __FILE__)

#       @body = load_body_template(template_path, @command)
#     end

#     def to_xml_unencrypted
#       construct_without_encryption(@body, @command, @ar, @sender_id, @request_id, @cert, @public_key, @environment).to_xml
#     end

#     def to_xml
#       construct(@body, @command, @ar, @sender_id, @request_id, @cert, @public_key, @environment).to_xml
#     end

#     private

#       # Creates the certificate request without encryption, needed for testing output structure
#       def construct_without_encryption(body, command, ar, sender_id, request_id, cert, public_key, environment)
#         set_body_contents(body, sender_id, request_id, environment)
#         add_unencrypted_request_to_soap(ar, body)
#       end

#       def construct(body, command, ar, sender_id, request_id, cert, public_key, environment)
#         set_body_contents(body, sender_id, request_id, environment)
#         encrypted_request = encrypt_application_request(ar, cert, public_key)
#         add_request_to_soap(encrypted_request, body)
#       end

#       def load_body_template(template_path, command)
#         case command
#         when :create_certificate
#           path = "#{template_path}/create_certificate.xml"
#         end

#         body_template = File.open(path)
#         body = Nokogiri::XML(body_template)
#         body_template.close

#         body
#       end

#       def extract_public_key(cert)
#         pkey = cert.public_key
#         pkey = OpenSSL::PKey::RSA.new(pkey)

#         pkey
#       end

#       def set_body_contents(body, sender_id, request_id, environment)
#         set_node(body, 'pkif|SenderId', sender_id)
#         set_node(body, 'pkif|CustomerId', sender_id)
#         set_node(body, 'pkif|RequestId', request_id)
#         set_node(body, 'pkif|Timestamp', Time.now.iso8601)
#         set_node(body, 'pkif|InterfaceVersion', 1)
#         set_node(body, 'pkif|Environment', environment)
#       end

#       def set_node(doc, node, value)
#         doc.at_css(node).content = value
#       end
#       def add_unencrypted_request_to_soap(ar, body)
#         ar = Nokogiri::XML(ar.to_xml)
#         ar = ar.at_css('tns|CreateCertificateRequest')
#         body.at_css('pkif|CreateCertificateIn').add_child(ar)

#         body
#       end
#       def add_request_to_soap(encrypted_request, body)
#         encrypted_request = Nokogiri::XML(encrypted_request.to_xml)
#         encrypted_request = encrypted_request.at_css('xenc|EncryptedData')
#         body.at_css('pkif|CreateCertificateIn').add_child(encrypted_request)

#         body
#       end

#       def encrypt_application_request(ar, cert, public_key)
#         # Format certificate if using PEM format
#         #cert = cert.to_s
#         #cert = cert.split('-----BEGIN CERTIFICATE-----')[1]
#         #cert = cert.split('-----END CERTIFICATE-----')[0]
#         #cert.gsub!(/\s+/, "")
#         formatted_cert = Base64.encode64(cert.to_der)

#         # puts "----- ApplicationRequest PRE encryption -----"
#         ar = ar.canonicalize(
#           mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,
#           with_comments=false
#         )
#         # puts ar
#         # puts "----- ApplicationRequest PRE encryption -----"

#         # Encrypt ApplicationRequest and set key
#         cipher = OpenSSL::Cipher::Cipher.new('DES-EDE3-CBC')
#         cipher.encrypt
#         # Option 1
#         #key = SecureRandom.hex(16)
#         key = cipher.random_key
#         cipher.key = key
#         # Option2
#         #iv = cipher.random_iv
#         #iv = SecureRandom.hex(16)
#         #cipher.iv = iv

#         output = cipher.update(ar)
#         output << cipher.final

#         #built_cipher = "02 | 45465519283985986 | 00 | #{key}"

#         # Base64 encode and encrypt key and set as content for encrypted application request
#         ciphervalue1 = Base64.encode64(public_key.public_encrypt(key))
#         ciphervalue2 = Base64.encode64(output)

#         # Build the xml to contain encrypted fields
#         builder = Nokogiri::XML::Builder.new do |xml|
#           xml['xenc'].EncryptedData('xmlns:xenc' => "http://www.w3.org/2001/04/xmlenc#", 'Type' => "http://www.w3.org/2001/04/xmlenc#Element") {
#             xml.EncryptionMethod('Algorithm' => "http://www.w3.org/2001/04/xmlenc#tripledes-cbc") {
#             }
#             xml['dsig'].KeyInfo('xmlns:dsig' => "http://www.w3.org/2000/09/xmldsig#"){
#                xml['xenc'].EncryptedKey('Recipient' =>"name:DanskeBankCryptCERT"){
#                     xml.EncryptionMethod('Algorithm' => "http://www.w3.org/2001/04/xmlenc#rsa-1_5")
#                     xml['dsig'].KeyInfo {
#                          xml.X509Data {
#                          xml.X509Certificate formatted_cert
#                          }
#                     }
#                     xml['xenc'].CipherData{
#                          xml.CipherValue ciphervalue1
#                     }
#                }
#             }
#             xml['xenc'].CipherData{
#                          xml.CipherValue ciphervalue2
#                     }
#           }
#         end

#       builder
#       end
#   end
# end
