# This app can be used to test the functionality of the sepa client

require 'sepa'

# Define certificate paths (These are not needed if testing Certificate service)
private_key = OpenSSL::PKey::RSA.new(File.read("sepa/nordea_testing/keys/nordea.key"))
cert = OpenSSL::X509::Certificate.new(File.read("sepa/nordea_testing/keys/nordea.crt"))

#1. The administrator makes agreement for the company using Web Services and receives 10-
#digit activation code to his/her mobile phone via SMS. It is valid for 7 days, but a new one can
#be ordered again from the branch office or from eSupport for corporate customers (see
#chapter 1.9)

#2. Banking software generates certificate signing request using the following information,
#which must be available when requesting a certificate from Nordea
#  name of the company (when company specific certificate) as in agreement
#  UserID as in agreement
#  country code (e.g. FI)
#  10 digit SMS activation code received by administrator registered into the agreement

#3. Banking software creates key pair for certificate and generates PKCS#10 request
#  (private key is newer sent to the bank)
#  use: key length 1024bit, SHA-1 algorithm, DER –encoded
#  Subject info: CN=name, serialNumber=userID, C=country (as above)

# Create 1024bit sha1 private key and generate Certificate Signing Request with it using parameters from cert_req.conf
%x(openssl req -newkey rsa:1024 -keyout signing_key.pem -keyform PEM -out CSR.csr -outform DER -config cert_req.conf -nodes)

#4. Create HMAC seal
#  use DER coded PKCS#10 above as input
#  SMS-activation code as the key (10-digits)

# Test pin for nordea
pin = '1234567890'

# Open Certificate Signing Request PKCS#10
csr = OpenSSL::X509::Request.new(File.read ('CSR.csr'))

# Generate HMAC seal (SHA1 hash) with pin as key and PKCS#10 as message
hmacseal = OpenSSL::HMAC.hexdigest('sha1',pin,csr.to_der)

#6. Send PKCS#10 with HMAC seal to Nordea
#  using schema: CertApplicationRequest
#TODO validation against schema before sending??
# Assign the generated PKCS#10 to as payload (goes to Content element)
payload = csr.to_der
# Assign the calculated HMAC seal as hmac (goes to HMAC element)
hmac = hmacseal
# Assigns value for service (goes to Service element)
service = "service"

# The params hash is populated with the data that is needed for gem to function
params = {
  # Path for your own private key
  private_key: private_key,

  # Path to your certificate
  cert: cert,

  # Command :download_file_list, :upload_file, :download_file, :get_user_info OR :get_certificate, :get_service_certificates
  #command: :get_service_certificates,
  command: :get_certificate,

  # Unique customer ID
  customer_id: '11111111',
  #customer_id: '482430003',

  # Set the environment to be either PRODUCTION or TEST
  environment: 'PRODUCTION',

  # For filtering stuff. Must be either NEW, DOWNLOADED or ALL
  status: 'NEW',

  # Some specification of the folder which to access in the bank. I have no idea how this works however.
  target_id: '11111111A1',

  # Language must be either FI, EN or SV
  language: 'FI',

  # The WSDL file used by nordea. Is identical between banks except for the address.
  wsdl: 'sepa/wsdl/wsdl_nordea_cert.xml',

  # The actual payload to send.
  content: payload,

  hmac: hmac,

  #activation_code: activation_code,

  service: service


}

# You just create the client with the parameters described above.
sepa_client = Sepa::Client.new(params)

sepa_client.send

# Decodes response to readable form
puts sepa_client.get_ar_as_string
