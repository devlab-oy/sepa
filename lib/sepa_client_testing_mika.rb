# First the sepa gem is loaded by requiring it
require 'sepa'

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

  csr_path: 'sepa/nordea_testing/keys/CSR.csr',

  # Selected service (For testing: service, For real: ISSUER)
  service: 'service'

}

# You just create the client with the parameters described above.
sepa_client = Sepa::Client.new(params)

sepa_client.send

