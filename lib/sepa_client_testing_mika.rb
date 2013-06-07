# This app can be used to test the functionality of the sepa client

require 'sepa'

# Create 1024bit sha1 private key and generate Certificate Signing Request with it using parameters from cert_req.conf
%x(openssl req -newkey rsa:1024 -keyout signing_key.pem -keyform PEM -out CSR.csr -outform DER -config cert_req.conf -nodes)

# Test pin for nordea
pin = '1234567890'

# Open Certificate Signing Request PKCS#10
csr = OpenSSL::X509::Request.new(File.read ('CSR.csr'))

# Generate HMAC seal (SHA1 hash) with pin as key and PKCS#10 as message
hmacseal = OpenSSL::HMAC.digest('sha1',pin,csr.to_der)

# Assign the generated PKCS#10 to as payload (goes to Content element)
payload = csr.to_der

# Assign the calculated HMAC seal as hmac (goes to HMAC element)
hmac = hmacseal

# Assigns value for service (goes to Service element)

# The params hash is populated with the data that is needed for gem to function
params = {
  # Command :download_file_list, :upload_file, :download_file, :get_user_info OR :get_certificate, :get_service_certificates
  command: :get_certificate,

  # Unique customer ID
  customer_id: '11111111',

  # Set the environment to be either PRODUCTION or TEST
  environment: 'TEST',

  # Language must be either FI, EN or SV
  language: 'FI',

  # The WSDL file used by nordea. Is identical between banks except for the address.
  wsdl: 'sepa/wsdl/wsdl_nordea_cert.xml',

  # The actual payload to send.
  content: payload,

  # HMAC seal
  hmac: hmac,

  # Selected service
  service: 'service'

}

# You just create the client with the parameters described above.
sepa_client = Sepa::Client.new(params)

sepa_client.send

# TODO Saving of certificate from response into a local file
