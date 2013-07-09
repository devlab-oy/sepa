# First the sepa gem is loaded by requiring it
require 'sepa'

debtor = {
  name: 'Testi Maksaja Oy',
  address: 'Testikatu 45',
  country: 'FI',
  postcode: '00100',
  town: 'Helsinki',
  customer_id: '111111111',
  y_tunnus: '1234',
  iban: 'FI4819503000000010',
  bic: 'NDEAFIHH'
}

payment = {
  execution_date: Date.new.iso8601,
  payment_info_id: '123456789',
  payment_id: '987654321',
  end_to_end_id: '1234',
  amount: '30',
  currency: 'EUR',
  clearing: '',
  ref: '123',
  message: 'Moikka'
}

creditor = {
  bic: 'NDEAFIHH',
  name: 'Testi Saaja Oy',
  address: 'Kokeilukatu 66',
  country: 'FI',
  postcode: '00200',
  town: 'Helsinki',
  iban: 'FI7429501800000014'
}

payload = Sepa::Payload.new(debtor, payment, creditor)
payload = payload.to_xml

# Keys
private_key = OpenSSL::PKey::RSA.new(
  File.read("sepa/nordea_testing/keys/nordea.key")
)
cert = OpenSSL::X509::Certificate.new(
  File.read("sepa/nordea_testing/keys/nordea.crt")
)

# The params hash is populated with the data that is needed for gem to function.
params = {
  # Path for your own private key.
  private_key: private_key,

  # Path to your certificate
  cert: cert,

  # Command :download_file_list, :upload_file, :download_file or :get_user_info.
  command: :upload_file,

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
  file_type: 'NDCORPAYS',

  # The WSDL file used by nordea. Is identical between banks except for the
  # address.
  wsdl: 'sepa/wsdl/wsdl_nordea.xml',

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
