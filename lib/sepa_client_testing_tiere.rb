# This app can be used to test the functionality of the sepa client

require 'sepa'

# payload = File.open("SOLOLMP.DAT").read
payload = "kissa"

params = {
  private_key: 'sepa/nordea_testing/keys/nordea.key', # Path for your own private key
  cert: 'sepa/nordea_testing/keys/nordea.crt',        # Path to your certificate
  command: :download_file_list,                            # Command :download_file_list, :upload_file, :download_file or :get_user_info
  customer_id: '11111111',                            # Unique customer ID
  environment: 'PRODUCTION',                          # Set the environment to be either PRODUCTION or TEST
  status: 'NEW',                                      # For filtering stuff. Must be either NEW, DOWNLOADED or ALL
  target_id: '11111111A1',                            # Some specification of the folder which to access in the bank. I have no idea how this works however.
  language: 'FI',                                     # Language must be either FI, EN or SV
  file_type: 'TITO',                                  # File types to upload or download:
                                                        # - LMP300 = Laskujen maksupalvelu (lähtevä)
                                                        # - LUM2 = Valuuttamaksut (lähtevä)
                                                        # - KTL = Saapuvat viitemaksut (saapuva)
                                                        # - TITO = Konekielinen tiliote (saapuva)
                                                        # - NDCORPAYS = Yrityksen maksut XML (lähtevä)
                                                        # - NDCAMT53L = Konekielinen XML-tiliote (saapuva)
                                                        # - NDCAMT54L = Saapuvat XML viitemaksu (saapuva)
  wsdl: 'sepa/wsdl/wsdl_nordea.xml',                  # The WSDL file used by nordea. Is identical between banks except for the address.
  content: payload,                                   # The actual payload to send.
  file_reference: "11111111A12006030329501800000014"  # File reference for :download_file command
}

sepa_client = Sepa::Client.new(params)            # You just create the client with the parameters described above.

puts sepa_client.get_ar_as_string