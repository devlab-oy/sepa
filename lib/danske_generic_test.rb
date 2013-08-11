require 'sepafm'

private_key_path = File.expand_path(
  '../sepa/danske_testing/keys/signing_private_key.pem', __FILE__
)

cert_path = File.expand_path(
  '../sepa/danske_testing/keys/own_signing_cert.pem', __FILE__
)

params = {

  bank: :danske,

  private_key_path: private_key_path,

  command: :get_user_info,

  customer_id: '360817',

  environment: 'customertest',

  key_generator_type: 'software',

  cert_path: cert_path,

  language: 'FI',

  status: 'ALL',

  target_id: '1234',

  file_type: 'xml'
}

sepa_client = Sepa::Client.new(params)

sepa_client.send
