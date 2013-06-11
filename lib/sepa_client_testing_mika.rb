# First the sepa gem is loaded by requiring it
require 'sepa'

# A test payload with no actual data
payload = "test_payload"

# Keys
private_key = OpenSSL::PKey::RSA.new(File.read("danske/root_certificate/META-INF/DBH12.RSA"))
cert = OpenSSL::X509::Certificate.new(File.read("danske/root_certificate/DBGROOT_1111110002.cer"))

# The params hash is populated with the data that is needed for gem to function
params = {
  # Path for your own private key
  private_key: private_key,

  # Path to your certificate
  cert: cert,

  # Command :download_file_list, :upload_file, :download_file or :get_user_info
  command: :get_user_info,

  # Unique customer ID
  customer_id: 'ABC123',

  # Set the environment to be either PRODUCTION or TEST
  environment: 'TEST',

  # For filtering stuff. Must be either NEW, DOWNLOADED or ALL
  status: 'NEW',

  # Some specification of the folder which to access in the bank. I have no idea how this works however.
  target_id: 'Danske Bank',

  # Language must be either FI, EN or SV
  language: 'EN',

  # File types to upload or download:
  # - LMP300 = Laskujen maksupalvelu (lähtevä)
  # - LUM2 = Valuuttamaksut (lähtevä)
  # - KTL = Saapuvat viitemaksut (saapuva)
  # - TITO = Konekielinen tiliote (saapuva)
  # - NDCORPAYS = Yrityksen maksut XML (lähtevä)
  # - NDCAMT53L = Konekielinen XML-tiliote (saapuva)
  # - NDCAMT54L = Saapuvat XML viitemaksu (saapuva)
  file_type: 'TITO',

  # The WSDL file used by nordea. Is identical between banks except for the address.
  wsdl: 'danske/BankCorporateFileService.xml',

  # The actual payload to send.
  content: payload,

  # File reference for :download_file command
  file_reference: "11111111A12006030329501800000014"
}

# You just create the client with the parameters described above.
sepa_client = Sepa::Client.new(params)

sepa_client.send