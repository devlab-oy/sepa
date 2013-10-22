# Generates a keypair, certificate and a certificate request and writes them
# to pem files in the same folder

require 'openssl'

key = OpenSSL::PKey::RSA.new 2048
public_key = key.public_key

name = OpenSSL::X509::Name.parse 'CN=hemuli/DC=nuuskamuikkunen'

cert = OpenSSL::X509::Certificate.new
cert.subject = cert.issuer = name
cert.not_before = Time.now
cert.not_after = Time.now + 365 * 24 * 60 * 60
cert.public_key = public_key
cert.serial = 0x0
cert.version = 2

ef = OpenSSL::X509::ExtensionFactory.new
ef.subject_certificate = cert
ef.issuer_certificate = cert
cert.extensions = [
  ef.create_extension("basicConstraints", "CA:TRUE", true),
  ef.create_extension("subjectKeyIdentifier", "hash")
]

cert.add_extension ef.create_extension("authorityKeyIdentifier",
                                       "keyid:always,issuer:always")

cert.sign key, OpenSSL::Digest::SHA1.new

csr = OpenSSL::X509::Request.new
csr.version = 1
csr.subject = name
csr.public_key = key.public_key
csr.sign key, OpenSSL::Digest::SHA1.new

open 'private_key.pem', 'w' do |io| io.write key.to_pem end
open 'public_key.pem', 'w' do |io| io.write key.public_key.to_pem end
open 'cert.pem', 'w' do |io| io.write cert.to_pem end
open 'certificate_request.pem', 'w' do |io|
  io.write csr.to_pem
end