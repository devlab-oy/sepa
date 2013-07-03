# First the sepa gem is loaded by requiring it
require 'sepa'

# Create 1024bit sha1 private key and generate Certificate Signing Request with it using parameters from cert_req.conf
#%x(openssl req -newkey rsa:1024 -keyout req_key.pem -keyform PEM -out CSR.csr -outform DER -config cert_req.conf -nodes)
#%x(rm signing_key.pem)

# Test pin for nordea
#pin = '1234567890'

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

  csr_path: 'CSR.csr',
  # HMAC seal
  #hmac: hmac,

  # Selected service (For testing: service, For real: ISSUER)
  service: 'service'

}

# You just create the client with the parameters described above.
sepa_client = Sepa::Client.new(params)

sepa_client.send

# TODO Saving of certificate from response into a local file
