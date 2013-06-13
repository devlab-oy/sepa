require 'sepa'

# Bank root cert
cert = OpenSSL::X509::Certificate.new(File.read("sepa/danske_testing/keys/danske.crt"))

# Extract public key from bank root certificate
public_key = cert.public_key
public_key = OpenSSL::PKey::RSA.new(public_key)

# Create encryption key and pkcs10 request
%x(openssl req -newkey rsa:2048 -keyout danske_encryption_key.pem -keyform PEM -out encryption_pkcs.csr -outform DER -config req.conf -nodes)

# Create signing key and pkcs10 request
%x(openssl req -newkey rsa:2048 -keyout danske_signing_key.pem -keyform PEM -out signing_pkcs.csr -outform DER -config req.conf -nodes)

encryption_pkcs = OpenSSL::X509::Request.new(File.read ('encryption_pkcs.csr'))
signing_pkcs = OpenSSL::X509::Request.new(File.read ('signing_pkcs.csr'))

idone = SecureRandom.random_number(1000).to_s
idtwo = SecureRandom.random_number(1000).to_s<<idone
puts "Todays lucky number was #{idtwo}"
params = {

          public_key: public_key,

          command: :create_certificate,

          wsdl: 'sepa/wsdl/wsdl_danske_cert.xml',

          request_id: idtwo,

          customer_id: 'ABC123',

          environment: 'customertest',

          key_generator_type: 'software',

          encryption_cert_pkcs10: encryption_pkcs.to_der,

          signing_cert_pkcs10: signing_pkcs.to_der,

          cert: cert,

          pin: '1234'
}

sepa_client = Sepa::Client.new(params)

sepa_client.send
