# This app can be used to test the functionality of the sepa client

# require 'sepa'

# Testing functionality of the parser side
# process = Sepa::ApplicationResponse.new
# Comment in 1 animate_response out of 3 to debug reader with different types of responses
# process.animate_response("sepa/nordea_testing/response/download_filelist_response.xml")
# #puts "Status = NEW"
# #puts process.list_new_descriptors
# process.animate_response("sepa/nordea_testing/response/download_file_response.xml")
# process.animate_response("sepa/nordea_testing/response/get_user_info_response.xml")
# Comment out to test content attribute passing
# puts process.get_account_statement_content("sepa/nordea_testing/response/content_053.xml")
# puts process.get_debit_credit_notification_content("sepa/nordea_testing/response/content_054.xml")

require 'sepa'
private_key = OpenSSL::PKey::RSA.new(File.read("sepa/nordea_testing/keys/nordea.key"))
cert = OpenSSL::X509::Certificate.new(File.read("sepa/nordea_testing/keys/nordea.crt"))

# Test activation code
activation_code = '1234567890'

#payload = Base64.decode64("MIIBdTCB3wIBADA4MQswCQYDVQQGEwJGSTETMBEGA1UEBRMKMjEyMjA2NjA1MTEUMBIGA1UEAwwLUGV0cmkgTHVvdG8wgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAKXysYu33QDqEVfYF6wSyBFzKRBll2UcOjdvT6hhojYTWKTzgCuS8WmVo5PSzmg9xoDkkJC65EceKKdyJcqpw7G7O1fD1aWvSuUs7ZfqaVi5BqG8ipVjKmFwy2pDqdlx0GmE9gk+7DQTuXm1n/jlkzhPKhFOibuivfboWdVQgyT9AgMBAAEwDQYJKoZIhvcNAQEFBQADgYEAUwh6/g4yYUrFg+Xp+4kPOJg17p/WjLUqt78KxK7xGkTsM1Oej/RZ2cra8Qcwsri22+ki7X9j4thJ1jxf0RLptfnGRNkdDql2UPRebQ0f5r8G0wwMQTbtkxZ2hBX7nEgss00TkRBwzESB9hUdLHyjzMwPlOkrZSeaqrSyNmJbL3w=")
payload = "pay me, im a load"

# The params hash is populated with the data that is needed for gem to function
params = {
  # Path for your own private key
  private_key: private_key,

  # Path to your certificate
  cert: cert,

  # Command :download_file_list, :upload_file, :download_file or :get_user_info
  #command: :get_service_certificates,
  command: :get_certificate,

  # Unique customer ID
  customer_id: '11111111',
  #customer_id: '1',

  # Set the environment to be either PRODUCTION or TEST
  environment: 'TEST',

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
  wsdl: 'sepa/wsdl/wsdl_nordea_cert.xml',

  # The actual payload to send.
  content: payload,

  activation_code: activation_code,

  # File reference for :download_file command
  # file_reference: "11111111A12006030329501800000014"
}

# You just create the client with the parameters described above.
sepa_client = Sepa::Client.new(params)

sepa_client.send