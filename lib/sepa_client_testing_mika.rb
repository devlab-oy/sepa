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

#payload = Base64.decode64("MIIDCTCCAnICAQAwOjEXMBUGA1UEAxMOUGV0cmkgVC4gTHVvdG8xEjAQBgNVBAUT
#CTY3OTE1NTMzMDELMAkGA1UEBhMCRkkwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJ
#AoGBAJo41eSLt4P7FBwXZtFBNEks55y1sl2zdfRHqTH1QsfZvs5lKbkhIKRXWb6y
#Ifnw5pktY6nYYM+Jd6SwbZbtvuUTIHTtNxlGSkfvGOXndlczky3e7qRRFfKy9LFS
#WIAH7baVr/lDsTPxWXOOFxrTiyfWtTye0lrjvyRqWaBvBKdLAgMBAAGgggGNMBoG
#CisGAQQBgjcNAgMxDBYKNS4xLjI2MDAuMjB7BgorBgEEAYI3AgEOMW0wazAOBgNV
#HQ8BAf8EBAMCBPAwRAYJKoZIhvcNAQkPBDcwNTAOBggqhkiG9w0DAgICAIAwDgYI
#KoZIhvcNAwQCAgCAMAcGBSsOAwIHMAoGCCqGSIb3DQMHMBMGA1UdJQQMMAoGCCsG
#AQUFBwMCMIHxBgorBgEEAYI3DQICMYHiMIHfAgEBHk4ATQBpAGMAcgBvAHMAbwBm
#AHQAIABTAHQAcgBvAG4AZwAgAEMAcgB5AHAAdABvAGcAcgBhAHAAaABpAGMAIABQ
#AHIAbwB2AGkAZABlAHIDgYkAbII1TrHis4afw+wbLrZIOYe1boagX3QNyHNj4kpk
#tRyBgIFt6WofQ1nXK6TXmpAm2/AmY20/h+a1GZ1/vn7EEzHcNQfjvHoSZH7yU5Fz
#vBVs5PGGZ//dlrlYX0iY8qhQicTdPQT3MRoYjUKBvi7IRJnfbWbpQKIZSweblEKN
#1IYAAAAAAAAAADANBgkqhkiG9w0BAQUFAAOBgQBSO7NiaLLu7vB3ZEMV7qjnBhPP
#7P7OjDsBG7G+4XFeqiRkpOPHDj9mb9PKp7SptH4rtv6bZZ4R3xnLWO74ZqIZuy3d
#GmwtTeBavOJLLRkdYZhVsBkRX4sAHTt0190G80jbl+5NJRpb/ii0e2Sm0x7gIu66
#qu8t+G80raOpKwI8CA==")

payload = Base64.encode64("k+ojfmSKUQItnkJWobwClJlRGqw=")

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
  #customer_id: '11111111',
  customer_id: '482430003',

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

  service: "service"

  # File reference for :download_file command
  # file_reference: "11111111A12006030329501800000014"
}

# You just create the client with the parameters described above.
sepa_client = Sepa::Client.new(params)

sepa_client.send