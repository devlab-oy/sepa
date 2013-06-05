require 'openssl'
require 'base64'
#1. The administrator makes agreement for the company using Web Services and receives 10-
#digit activation code to his/her mobile phone via SMS. It is valid for 7 days, but a new one can
#be ordered again from the branch office or from eSupport for corporate customers (see
#chapter 1.9)

#2. Banking software generates certificate signing request using the following information,
#which must be available when requesting a certificate from Nordea
#  name of the company (when company specific certificate) as in agreement
#  UserID as in agreement
#  country code (e.g. FI)
#  10 digit SMS activation code received by administrator registered into the agreement

# 3 above defined in cer.cfg, key in step 4

#3. Banking software creates key pair for certificate and generates PKCS#10 request
#  (private key is newer sent to the bank)
#  use: key length 1024bit, SHA-1 algorithm, DER –encoded
#  Subject info: CN=name, serialNumber=userID, C=country (as above)
#{}%x(openssl req -newkey rsa -keyout key.pem -out certificate_request.der -passout pass:1234 -outform DER -config cer.cnf)

#4. Create HMAC seal
#  use DER coded PKCS#10 above as input
#  SMS-activation code as the key (10-digits)

#key = '1234567890'

#der = File.binread("certificate_request.der")
#certrequest = OpenSSL::ASN1.decode(der)

#puts key
#puts der.inspect
#puts certrequest.inspect

#%x(openssl asn1parse -inform DER -in certificate_request.der)
#digest  = OpenSSL::Digest::Digest.new('sha1')

#hmacseal = OpenSSL::HMAC.digest(digest,key, certrequest.to_s)
#hmacseal = Base64.encode64(hmacseal)

#6. Send PKCS#10 with HMAC seal to Nordea
#  using schema: CertApplicationRequest
#   put PKCS#10 in base64 format to Content element
#payload = Base64.encode64(der)
#   put calculated HMAC to HMAC element
#hmac = Base64.encode64(hmacseal)
#   put code “service” to Service-element
#service = "service"
#   put “GetCertificate” to Command element
#command = :get_certificate
#  place CertApplicationRequest in base64-encoded format in body element of the
#  SOAP
#  SOAP message need not to be signed

#puts OpenSSL::ASN1.decode(der).to_der
#puts certrequest.to_der

#value = "sha1"

#kempo = OpenSSL::HMAC.new(key,value)
#puts kempo
#
#File.open("hmac.pem", 'w') { |file| file.write(kempo.to_s) }


#digest = Base64.encode64("kissa")
#digest = 'kissa'
#OpenSSL::HMAC.new(key,value)
#skartje = OpenSSL::HMAC::digest(value,key,digest)
#puts skartje
#puts Base64.encode64(skartje)


#OpenSSL::HMAC.hexdigest('sha1', key, signature)

require 'cgi'

#key = '1234'
#signature = 'kissa'
#puts CGI.escape(Base64.encode64("#{OpenSSL::HMAC.digest('sha1',key, signature)}\n"))

#puts OpenSSL::HMAC.hexdigest('sha1', key, signature)

#digest  = OpenSSL::Digest::Digest.new('sha1')
#puts OpenSSL::HMAC.digest(digest,key, certrequest.to_der)
#puts OpenSSL::HMAC.hexdigest('sha1',key, certrequest.to_der)

#der = File.binread("certificate_request.der")

#certrequest = IO.read("certificate_request.der")
#
#puts "------------IOREAD/:-----------"
#puts certrequest
#
#certrequest = File.binread("certificate_request.der")
#
#puts "------------BINREAD/:-----------"
#puts certrequest
#
#certrequest = OpenSSL::ASN1.decode(certrequest)
#
#puts "------------ASN1.DECODE/:-----------"
#puts certrequest.to_der
#
#
#OpenSSL::PKCS10.new(IO.read("key.pem"))

#original backup
#openssl req -newkey rsa:1024 -keyout signing_key.pem -keyform PEM -out signing_cert_req.pem -outform pem -config cert_req.conf -nodes

#INCLUDE cert_req.conf with this
%x(openssl req -newkey rsa:1024 -keyout signing_key.pem -keyform PEM -out CSR.csr -outform DER -config cert_req.conf -nodes)

#VERIFY DER format CSR
#openssl req -text -noout -verify -inform DER -in CSR.csr

#MODULUS
#openssl req -noout -modulus -inform DER -in CSR.csr | openssl md5

#openssl x509 -in keytool_crt.der -inform der -noout -text
#openssl req -text -noout -verify -in signing_cert_req.pem

#Working verifying of der form request
#openssl req -text -noout -verify -inform DER -in signing_cert_req.der
#raw = File.binread("CSR.csr") # DER- or PEM-encoded
#certificate = OpenSSL::X509::Certificate.new(raw)
#OpenSSL::X509::Certificate.new(File.read("sepa/nordea_testing/keys/nordea.crt"))
#puts certificate

#puts OpenSSL::HMAC.hexdigest('sha1','1234567890',raw)

csr = OpenSSL::X509::Request.new(File.read ('CSR.csr'))
puts csr

#puts OpenSSL::HMAC.hexdigest('sha1','1234567890',csr)

puts "Next line should be 0xde7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9"
puts OpenSSL::HMAC.hexdigest('sha1','key','The quick brown fox jumps over the lazy dog')
puts "Next line should be 0xfbdb1d1b18aa6c08324b7d64b71fb76370690e1d"
puts OpenSSL::HMAC.hexdigest('sha1','','')
puts OpenSSL::HMAC.digest('sha1','','')
