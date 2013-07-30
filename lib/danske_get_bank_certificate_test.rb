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

# You just create the client with the parameters described above.
sepa_client = Sepa::Client.new(params)

response = sepa_client.send
response = Nokogiri::XML(response.to_xml)
response = Sepa::Response.new(response)

# ar = Sepa::ApplicationResponse.new(response.application_response)

# puts "\n\nHashes match in the response: #{response.hashes_match?}"
# puts "Signature is valid in the response: #{response.signature_is_valid?}"

# puts "\nHashes match in the application response: #{ar.hashes_match?}"
# puts "Signature is valid in the application response: #{ar.signature_is_valid?}"

# puts "\nSome info about response's certificate:\n" \

#   "Issuer: #{response.certificate.issuer}\n" \
#   "First day to use this certificate: #{response.certificate.not_before}\n" \
#   "Expires: #{response.certificate.not_after}"

# puts "\nSome info about application response's certificate:\n" \
#   "Issuer: #{ar.certificate.issuer}\n" \
#   "First day to use this certificate: #{ar.certificate.not_before}\n" \
#   "Expires: #{ar.certificate.not_after}"

data = response.get_important_data(:get_bank_certificate)
puts data
