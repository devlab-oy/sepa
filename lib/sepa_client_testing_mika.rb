# First the sepa gem is loaded by requiring it
require 'sepafm'

# The params hash is populated with the data that is needed for gem to function
params = {
  # Test pin for nordea
  pin: '1234567890',

  # Selected bank
  bank: :nordea,

  # Command for CertificateService :get_certificate
  command: :get_certificate,

  # Unique customer ID
  customer_id: '11111111',

  # Set the environment to be either PRODUCTION or TEST
  environment: 'TEST',

  csr_plain: "-----BEGIN CERTIFICATE REQUEST-----
MIIBczCB3QIBADA0MRIwEAYDVQQDEwlEZXZsYWIgT3kxETAPBgNVBAUTCDExMTEx
MTExMQswCQYDVQQGEwJGSTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAo9wU
c2Ys5hSso4nEanbc+RIhL71aS6GBGiWAegXjhlyb6dpwigrZBFPw4u6UZV/Vq7Y7
Ku3uBq5rfZwk+lA+c/B634Eu0zWdI+EYfQxKVRrBrmhiGplKEtglHXbNmmMOn07e
LPUaB0Ipx/6h/UczJGBINdtcuIbYVu0r7ZfyWbUCAwEAAaAAMA0GCSqGSIb3DQEB
BQUAA4GBAIhh2o8mN4Byn+w1jdbhq6lxEXYqdqdh1F6GCajt2lQMUBgYP23I5cS/
Z+SYNhu8vbj52cGQPAwEDN6mm5yLpcXu40wYzgWyfStLXV9d/b4hMy9qLMW00Dzb
jo2ekdSDdw8qxKyxj1piv8oYzMd4fCjCpL+WDZtq7mdLErVZ92gH
-----END CERTIFICATE REQUEST-----",

  # Selected service (For testing: service, For real: ISSUER)
  service: 'service'

}

# You just create the client with the parameters described above.
sepa_client = Sepa::Client.new(params)
puts sepa_client.inspect
#puts sepa_client.methods
puts sepa_client.errors.full_messages
# Response is created by triggering 'send_request' from client
response = sepa_client.send_request
puts response.inspect
# Response contains methods valid? and payload
# puts response.payload if response.valid?

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

