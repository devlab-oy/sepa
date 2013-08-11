require 'sepafm'

params = {
  bank: :danske,
  target_id: 'Danske FI',
  language: 'EN',
  command: :get_bank_certificate,
  bank_root_cert_serial: '1111110002',
  customer_id: '360817',
  environment: 'TEST',
  key_generator_type: 'software'
}

sepa_client = Sepa::Client.new(params)

response = sepa_client.send
response = Nokogiri::XML(response.to_xml)
response = Sepa::Response.new(response)

puts "Bank's encryption certificate:\n\n"
puts response.danske_bank_encryption_cert

puts "\nBank's signing certificate:\n\n"
puts response.danske_bank_signing_cert

puts "\nBank's root certificate:\n\n"
puts response.danske_bank_root_cert
