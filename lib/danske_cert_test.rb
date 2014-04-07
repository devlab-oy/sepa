require 'sepafm'

encryptpkcsplain = "-----BEGIN CERTIFICATE REQUEST-----
MIICdzCCAV8CAQEwMjEPMA0GA1UEAwwGaGVtdWxpMR8wHQYKCZImiZPyLGQBGRYP
bnV1c2thbXVpa2t1bmVuMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
5aHmVXcfogDqJ3kUfK8ARzdkQ/dm9j4rHbGNh4xmlKCMUwCmmo2LOKMKvviD7qwz
n1lDsPIClbmZaxc3vFlpNj5A6YVg7SpCU/Cx9RtTY+2vWQF29RWw5UktPDALIRNC
boKuNykWqbWhwW80YOO3MXlASw2EF2nfsxLGXNmiB7kKaxPrTsNV9CO4rVIrYJj5
2+1MZSEhEQn9H9VrKgCNlDN/6LCs/TnSC7Np1jOTjo5Nen95afE0KUEbSnMw8Ihw
ymOFF0zgxiCQ1kme5fYXqCZZJOU+zS3pKO/LdnULu6/uJ1D0JWjIwWBqEwTwMqhj
NnsJaoJiJJnQtuFcVIhXEQIDAQABoAAwDQYJKoZIhvcNAQEFBQADggEBAAlVfy+G
GUPYnTfrRoBvgSMz5dR7rynQe5wxHWTtk71xbODSIZNFUntYa4tSAzaIEp65FxTj
WyGlBZcdzCPd39DJtfxeiZ8q4UKx47VCt4jIzOSpM2jvGzlUpHnm2Eh9rQHqMRye
C4T49gWBEqsTvZL+hWE9dAQq4Y+P3h9UWr49bMQNbSxERw3fDzWvcEJsSq+4Ml12
+sPV+Euz5phCzqt15v+6jfqlEgGj27k3MlF+EglX0BWduGw4RxfoOdGQNBwdXPkz
db1f0XsYTW1NUYoL8O8uxzoNcysyBW/VGP01e2LXB8whWn4xtDtaLpyt/v4ow04V
9v3lfL5ZDl1gIEY=
-----END CERTIFICATE REQUEST-----"

signingpkcsplain = "-----BEGIN CERTIFICATE REQUEST-----
MIICdzCCAV8CAQEwMjEPMA0GA1UEAwwGaGVtdWxpMR8wHQYKCZImiZPyLGQBGRYP
bnV1c2thbXVpa2t1bmVuMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
y4zgajeMzFrBR4zsJ50qo4fxHWfjdCmI5nwLbKqKhSKB15JBdRmh/Wz0Gi1qOvER
x9wS5c/1pMr1ARcVUvz2425ZNV77AAQMGUZpLxP9N6QWK39u4VemoecdPfNYv/tt
qk1cJFO1aNNmIMrDzBZEzQH/Mf4QbiqsaSvuVay8mjVEW3she4FbcrhNnhlm3PS7
XOm0UF2TiCjrM4enCI2XhTzKnSxONiM8KubKEAEOXPDAYGRwn+dik30qYwT5kMbG
tzggHPsiwkBUDEcNeMuMGRKNxP3i03DA4wGSJZu3A61TcYVLihj9hEDnybe7Dw0h
eNmyqoqp/0gr89rxlAANNwIDAQABoAAwDQYJKoZIhvcNAQEFBQADggEBAEbyXe6f
aBGbaSldlIceYyxIXVqBRwVuE22vvk6to1f+QYrWj+4IexD0TBdfpcpKATnOjqEH
sbksB0HOKZmFDCqNZamw1458DtdtSPpOn5EyX9BX6K2hExmj5CV1vEORB8dQ4lBi
zjrpAOh422NQ3galu1vfrPVvRS8lN4t+zJUlBoCUwPlm5AmH88dJCXDHTxDrwxxv
6UPUROxE2p+1TyHueUmfMKvjySnt8IIfoEvz4q/EouIbL2lDJwXOwX+1fx4Rva6t
bx1hmt5Eihy1lORQR4PE4xaOP5TCqtxP0+snuGqRuBHhrDk4mowWEJbvFWlONT5H
CsajqZag/Aoxv/Y=
-----END CERTIFICATE REQUEST-----"

enc_cert_path = File.expand_path(
  '../sepa/danske_testing/keys/bank_encryption_cert.pem', __FILE__
)

params = {
  bank: :danske,
  enc_cert_path: enc_cert_path,
  command: :create_certificate,
  customer_id: '360817',
  environment: 'customertest',
  key_generator_type: 'software',
  encryption_cert_pkcs10_plain: encryptpkcsplain,
  signing_cert_pkcs10_plain: signingpkcsplain,
  pin: '1234'
}

sepa_client = Sepa::Client.new(params)

response = sepa_client.send
response = Nokogiri::XML(response.to_xml)
response = Sepa::Response.new(response)

puts "Own encryption certificate:\n\n"
puts response.own_encryption_cert

puts "\nOwn signing certificate:\n\n"
puts response.own_signing_cert
