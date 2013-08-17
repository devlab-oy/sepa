require 'sepafm'

private_key_path = File.expand_path(
  '../sepa/danske_testing/keys/signing_private_key.pem', __FILE__
)

signing_cert_path = File.expand_path(
  '../sepa/danske_testing/keys/own_signing_cert.pem', __FILE__
)

enc_cert_path = File.expand_path(
  '../sepa/danske_testing/keys/bank_encryption_cert.pem', __FILE__
)

params = {
  bank: :danske,
  private_key_path: private_key_path,
  command: :upload_file,
  customer_id: '360817',
  environment: 'TEST',
  enc_cert_path: enc_cert_path,
  cert_path: signing_cert_path,
  language: 'EN',
  status: 'ALL',
  target_id: 'Danske FI',
  file_type: 'pain.001.001.02',
  content: Base64.encode64('kissa')
}

sepa_client = Sepa::Client.new(params)

sepa_client.send
