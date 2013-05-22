# First the sepa gem is loaded by requiring it
require 'sepa'

# A test payload with no actual data
payload = "test_payload"

# The params hash is populated with the data that is needed for gem to function
params = {
  # Path for your own private key
  private_key: 'sepa/nordea_testing/keys/nordea.key',

  # Path to your certificate
  cert: 'sepa/nordea_testing/keys/nordea.crt',

  # Command :download_file_list, :upload_file, :download_file or :get_user_info
  command: :download_file,

  # Unique customer ID
  customer_id: '11111111',

  # Set the environment to be either PRODUCTION or TEST
  environment: 'PRODUCTION',

  # For filtering stuff. Must be either NEW, DOWNLOADED or ALL
  status: 'NEW',

  # Some specification of the folder which to access in the bank. I have no idea how this works however.
  target_id: '11111111A1',

  # Language must be either FI, EN or SV
  language: 'FI',

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
  wsdl: 'sepa/wsdl/wsdl_nordea.xml',

  # The actual payload to send.
  content: payload,

  # File reference for :download_file command
  file_reference: "11111111A12006030329501800000014"
}

# You just create the client with the parameters described above.
sepa_client = Sepa::Client.new(params)

sepa_client.send