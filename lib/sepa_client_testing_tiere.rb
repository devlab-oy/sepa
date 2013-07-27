# First the sepa gem is loaded by requiring it
require 'sepa'

trans_1_params = {
  instruction_id: '70CEF29BEBA8396A1F806005EDA51DEE4CE',
  end_to_end_id: '629CADFDAD5246AD915BA24A3C8E9FC3313',
  amount: '30.75',
  currency: 'EUR',
  bic: 'NDEAFIHH',
  name: 'Testi Saaja Oy',
  address: 'Kokeilukatu 66',
  country: 'FI',
  postcode: '00200',
  town: 'Helsinki',
  iban: 'FI7429501800000014',
  reference: '00000000000000001245',
  message: 'Maksu'
}

trans_2_params = {
  instruction_id: 'A552D3EBB207B4AC17DF97C7D548A0571B0',
  end_to_end_id: 'CDE1206C8745D6FBDCD2BBB02DB6CB6D3BE',
  amount: '1075.20',
  currency: 'EUR',
  bic: 'NDEAFIHH',
  name: 'Testing Company',
  address: 'Tynnyrikatu 56',
  country: 'FI',
  postcode: '00600',
  town: 'Helsinki',
  iban: 'FI7429501800000014',
  reference: '000000000000000034795',
  message: 'Siirto'
}

trans_3_params = {
  instruction_id: '44DB2850ABDFBEF2A32D0EE511BE5AB0B79',
  end_to_end_id: 'A107CF858A22116D0C8EC1E78B078794B8C',
  amount: '10000',
  currency: 'EUR',
  bic: 'NDEAFIHH',
  name: 'Best Company Ever',
  address: 'Banaanikuja 66',
  country: 'FI',
  postcode: '00900',
  town: 'Helsinki',
  iban: 'FI7429501800000014',
  reference: '000000000000000013247',
  message: 'Valuutan siirto toiselle tilille'
}

trans_4_params = {
  instruction_id: '16A0C311AF72F3F5E8B6704EB3B6086047C',
  end_to_end_id: 'B10CE2EC71DB76114DDA68C9DAAA77A59DB',
  amount: '12',
  currency: 'EUR',
  bic: 'NDEAFIHH',
  name: 'Testi Saaja Oy',
  address: 'Kokeilukatu 66',
  country: 'FI',
  postcode: '00200',
  town: 'Helsinki',
  iban: 'FI7429501800000014',
  reference: '00000000000000001245',
  message: 'Maksu'
}

trans_5_params = {
  instruction_id: 'E0C01A8D65EA0BAB7CF1D4337FBCC3D33D7',
  end_to_end_id: 'B10CE2EC71DB76114DDA68C9DAAA77A59DB',
  amount: '99.20',
  currency: 'EUR',
  bic: 'NDEAFIHH',
  name: 'Testing Company',
  address: 'Tynnyrikatu 56',
  country: 'FI',
  postcode: '00600',
  town: 'Helsinki',
  iban: 'FI7429501800000014',
  reference: '000000000000000034795',
  message: 'Siirto'
}

trans_6_params = {
  instruction_id: 'FD19CD1844B20B0E65E66EA307668B1C3F8',
  end_to_end_id: 'CE9FF7E7CE5961AA1207C828DBFE467182F',
  amount: '15000',
  currency: 'EUR',
  bic: 'NDEAFIHH',
  name: 'Best Company Ever',
  address: 'Banaanikuja 66',
  country: 'FI',
  postcode: '00900',
  town: 'Helsinki',
  iban: 'FI7429501800000014',
  reference: '000000000000000013247',
  message: 'Valuutan siirto toiselle tilille'
}

debtor = {
  name: 'Testi Maksaja Oy',
  address: 'Testing Street 12',
  country: 'FI',
  postcode: '00100',
  town: 'Helsinki',
  customer_id: '111111111',
  y_tunnus: '111111111',
  iban: 'FI4819503000000010',
  bic: 'NDEAFIHH'
}

payment_1_transactions = []
payment_2_transactions = []

payment_1_transactions.push(Sepa::Transaction.new(trans_1_params))
payment_1_transactions.push(Sepa::Transaction.new(trans_2_params))
payment_1_transactions.push(Sepa::Transaction.new(trans_3_params))

payment_2_transactions.push(Sepa::Transaction.new(trans_4_params))
payment_2_transactions.push(Sepa::Transaction.new(trans_5_params))
payment_2_transactions.push(Sepa::Transaction.new(trans_6_params))

payment_1_params = {
  payment_info_id: 'F56D46DDA136A981F58C05999479E768C92',
  execution_date: '2013-08-10',
  transactions: payment_1_transactions
}

payment_2_params = {
  payment_info_id: 'B60EECC432C306876FE3E23999DF7F43254',
  execution_date: '2013-08-15',
  transactions: payment_2_transactions
}

payments = []

payments.push(Sepa::Payment.new(debtor, payment_1_params))
payments.push(Sepa::Payment.new(debtor, payment_2_params))

payload = Sepa::Payload.new(debtor, payments)
payload = payload.to_xml

# The params hash is populated with the data that is needed for gem to function.
params = {

  bank: :nordea,

  cert_path: "sepa/nordea_testing/keys/nordea.crt",

  private_key_path: "sepa/nordea_testing/keys/nordea.key",

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
