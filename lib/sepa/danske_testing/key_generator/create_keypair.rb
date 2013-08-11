require 'openssl'

key = OpenSSL::PKey::RSA.new 2048

open 'private_key.pem', 'w' do |io| io.write key.to_pem end
open 'public_key.pem', 'w' do |io| io.write key.public_key.to_pem end

name = OpenSSL::X509::Name.parse 'CN=hemuli/DC=nuuskamuikkunen'

csr = OpenSSL::X509::Request.new
csr.version = 1
csr.subject = name
csr.public_key = key.public_key
csr.sign key, OpenSSL::Digest::SHA1.new

open 'certificate_request.pem', 'w' do |io|
  io.write csr.to_pem
end
