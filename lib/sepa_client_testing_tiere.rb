# First the sepa gem is loaded by requiring it
require 'sepa'

# A test payload with no actual data
payload = "test_payload"

# The params hash is populated with the data that is needed for gem to function.
params = {

  bank: :nordea,

  cert_path: "sepa/nordea_testing/keys/nordea.crt",

  private_key_path: "sepa/nordea_testing/keys/nordea.key",

  # Command :download_file_list, :upload_file, :download_file or :get_user_info.
  command: :get_user_info,

  # Unique customer ID.
  customer_id: '11111111',

  # Set the environment to be either PRODUCTION or TEST.
  environment: 'PRODUCTION',

  # For filtering stuff. Must be either NEW, DOWNLOADED or ALL.
  status: 'NEW',

  # Some specification of the folder which to access in the bank. I have no
  # idea how this works however.
  target_id: '11111111A1',

  # Language must be either FI, EN or SV.
  language: 'FI',

  # File types to upload or download:
  # - LMP300 = Laskujen maksupalvelu (lähtevä)
  # - LUM2 = Valuuttamaksut (lähtevä)
  # - KTL = Saapuvat viitemaksut (saapuva)
  # - TITO = Konekielinen tiliote (saapuva)
  # - NDCORPAYS = Yrityksen maksut XML (lähtevä)
  # - NDCAMT53L = Konekielinen XML-tiliote (saapuva)
  # - NDCAMT54L = Saapuvat XML viitemaksu (saapuva)
  file_type: 'TITO',

  # The WSDL file used by nordea. Is identical between banks except for the
  # address.
  #wsdl: 'sepa/wsdl/wsdl_nordea.xml',

  # The actual payload to send.
  content: payload,

  # File reference for :download_file command.
  file_reference: "11111111A12006030329501800000014"
}

# You just create the client with the parameters described above.
sepa_client = Sepa::Client.new(params)

response = sepa_client.send
response = Nokogiri::XML(response.to_xml)
response = Sepa::Response.new(response)

ar = Sepa::ApplicationResponse.new(response.application_response)

puts "\n\nHashes match in the response: #{response.hashes_match?}"
puts "Signature is valid in the response: #{response.signature_is_valid?}"

puts "\nHashes match in the application response: #{ar.hashes_match?}"
puts "Signature is valid in the application response: #{ar.signature_is_valid?}"

puts "\nSome info about response's certificate:\n" \

  "Issuer: #{response.certificate.issuer}\n" \
  "First day to use this certificate: #{response.certificate.not_before}\n" \
  "Expires: #{response.certificate.not_after}"

puts "\nSome info about application response's certificate:\n" \
  "Issuer: #{ar.certificate.issuer}\n" \
  "First day to use this certificate: #{ar.certificate.not_before}\n" \
  "Expires: #{ar.certificate.not_after}"
