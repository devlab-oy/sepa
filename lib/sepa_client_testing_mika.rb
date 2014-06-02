# First the sepa gem is loaded by requiring it
require 'sepafm'

# The params hash is populated with the data that is needed for gem to function
params = {
  # Test pin for nordea
  pin: '1234567890',

  # Selected bank
  bank: :nordea,

  # Command for CertificateService :get_certificate
  command: :get_certificate,

  # Unique customer ID
  customer_id: '11111111',

  # Set the environment to be either PRODUCTION or TEST
  environment: 'TEST',

  csr_plain: "-----BEGIN CERTIFICATE REQUEST-----
MIIBczCB3QIBADA0MRIwEAYDVQQDEwlEZXZsYWIgT3kxETAPBgNVBAUTCDExMTEx
MTExMQswCQYDVQQGEwJGSTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAo9wU
c2Ys5hSso4nEanbc+RIhL71aS6GBGiWAegXjhlyb6dpwigrZBFPw4u6UZV/Vq7Y7
Ku3uBq5rfZwk+lA+c/B634Eu0zWdI+EYfQxKVRrBrmhiGplKEtglHXbNmmMOn07e
LPUaB0Ipx/6h/UczJGBINdtcuIbYVu0r7ZfyWbUCAwEAAaAAMA0GCSqGSIb3DQEB
BQUAA4GBAIhh2o8mN4Byn+w1jdbhq6lxEXYqdqdh1F6GCajt2lQMUBgYP23I5cS/
Z+SYNhu8vbj52cGQPAwEDN6mm5yLpcXu40wYzgWyfStLXV9d/b4hMy9qLMW00Dzb
jo2ekdSDdw8qxKyxj1piv8oYzMd4fCjCpL+WDZtq7mdLErVZ92gH
-----END CERTIFICATE REQUEST-----",

  # Selected service (For testing: service, For real: ISSUER)
  service: 'service',

  language: 'FI',

  target_id: 1234,

  private_key_plain: "-----BEGIN PRIVATE KEY-----
MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMLRRHwLWybhs0MM
EbpmZL2IdgYxmFbADFHoirTp3t22UnorHwqvk16i9YCPS6H8ngEPSP7A5urS/NMq
w+YmklKlZugO9/TLJqVv4smXFX+5rPMQDedRElIDempMGQlPaR+tp4CQ49oFLJLW
NH6bKFbAEXa7zhZNH00lFylnei23AgMBAAECgYEAqt912/7x4jaQTrxlSELLFVp9
eo1BesVTiPwXvPpsGbbyvGjZ/ztkXNs9zZbh1aCGzZMkiR2U7F5GlsiprlIif4cF
6Xz7rCjaAs7iDRt9PjhjVuqNGR2I+VIIlbQ9XWFJ3lJFW3v7TIZ8JbLnn0XOFz+Z
BBSSGTK1zTNh4TBQtjECQQDe5M3uu9m4RwSw9R6GaDw/IFQZgr0oWSv0WIjRwvwW
nFnSX2lbkNAjulP0daGsmn7vxIpqZxPxwcrU4wFqTF5dAkEA38DnbCm3YfogzwLH
Nre2hBmGqjWarhtxqtRarrkgnmOd8W0Z1Hb1dSHrliUSVSrINbK5ZdEV15Rpu7VD
OePzIwJAPMslS+8alANyyR0iJUC65fDYX1jkZOPldDDNqIDJJxWf/hwd7WaTDpuc
mHmZDi3ZX2Y45oqUywSzYNtFoIuR1QJAZYUZuyqmSK77SdGB36K1DfSi9AFEQDC1
fwPAbTwTv6mFFPAiYxLiRZXxVPtW+QtjMXH4ymh2V4y/+GnCqbZyLwJBAJQSDAME
Sn4Uz7Zjk3UrBIbMYEv0u2mcCypwsb0nGE5/gzDPjGE9cxWW+rXARIs+sNQVClnh
45nhdfYxOjgYff0=
-----END PRIVATE KEY-----",

  cert_plain: "-----BEGIN CERTIFICATE-----
MIIDwTCCAqmgAwIBAgIEAX1JuTANBgkqhkiG9w0BAQUFADBkMQswCQYDVQQGEwJT
RTEeMBwGA1UEChMVTm9yZGVhIEJhbmsgQUIgKHB1YmwpMR8wHQYDVQQDExZOb3Jk
ZWEgQ29ycG9yYXRlIENBIDAxMRQwEgYDVQQFEws1MTY0MDYtMDEyMDAeFw0xMzA1
MDIxMjI2MzRaFw0xNTA1MDIxMjI2MzRaMEQxCzAJBgNVBAYTAkZJMSAwHgYDVQQD
DBdOb3JkZWEgRGVtbyBDZXJ0aWZpY2F0ZTETMBEGA1UEBRMKNTc4MDg2MDIzODCB
nzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAwtFEfAtbJuGzQwwRumZkvYh2BjGY
VsAMUeiKtOne3bZSeisfCq+TXqL1gI9LofyeAQ9I/sDm6tL80yrD5iaSUqVm6A73
9MsmpW/iyZcVf7ms8xAN51ESUgN6akwZCU9pH62ngJDj2gUsktY0fpsoVsARdrvO
Fk0fTSUXKWd6LbcCAwEAAaOCAR0wggEZMAkGA1UdEwQCMAAwEQYDVR0OBAoECEBw
2cj7+XMAMBMGA1UdIAQMMAowCAYGKoVwRwEDMBMGA1UdIwQMMAqACEALddbbzwun
MDcGCCsGAQUFBwEBBCswKTAnBggrBgEFBQcwAYYbaHR0cDovL29jc3Aubm9yZGVh
LnNlL0NDQTAxMA4GA1UdDwEB/wQEAwIFoDCBhQYDVR0fBH4wfDB6oHigdoZ0bGRh
cCUzQS8vbGRhcC5uYi5zZS9jbiUzRE5vcmRlYStDb3Jwb3JhdGUrQ0ErMDElMkNv
JTNETm9yZGVhK0JhbmsrQUIrJTI4cHVibCUyOSUyQ2MlM0RTRSUzRmNlcnRpZmlj
YXRlcmV2b2NhdGlvbmxpc3QwDQYJKoZIhvcNAQEFBQADggEBACLUPB1Gmq6286/s
ROADo7N+w3eViGJ2fuOTLMy4R0UHOznKZNsuk4zAbS2KycbZsE5py4L8o+IYoaS8
8YHtEeckr2oqHnPpz/0Eg7wItj8Ad+AFWJqzbn6Hu/LQhlnl5JEzXzl3eZj9oiiJ
1q/2CGXvFomY7S4tgpWRmYULtCK6jode0NhgNnAgOI9uy76pSS16aDoiQWUJqQgV
ydowAnqS9h9aQ6gedwbOdtkWmwKMDVXU6aRz9Gvk+JeYJhtpuP3OPNGbbC5L7NVd
no+B6AtwxmG3ozd+mPcMeVuz6kKLAmQyIiBSrRNa5OrTkq/CUzxO9WUgTnm/Sri7
zReR6mU=
-----END CERTIFICATE-----",

  status: 'NEW',

  file_type: 'kissa',

  csr_plain: "-----BEGIN CERTIFICATE REQUEST-----
MIIBczCB3QIBADA0MRIwEAYDVQQDEwlEZXZsYWIgT3kxETAPBgNVBAUTCDExMTEx
MTExMQswCQYDVQQGEwJGSTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAo9wU
c2Ys5hSso4nEanbc+RIhL71aS6GBGiWAegXjhlyb6dpwigrZBFPw4u6UZV/Vq7Y7
Ku3uBq5rfZwk+lA+c/B634Eu0zWdI+EYfQxKVRrBrmhiGplKEtglHXbNmmMOn07e
LPUaB0Ipx/6h/UczJGBINdtcuIbYVu0r7ZfyWbUCAwEAAaAAMA0GCSqGSIb3DQEB
BQUAA4GBAIhh2o8mN4Byn+w1jdbhq6lxEXYqdqdh1F6GCajt2lQMUBgYP23I5cS/
Z+SYNhu8vbj52cGQPAwEDN6mm5yLpcXu40wYzgWyfStLXV9d/b4hMy9qLMW00Dzb
jo2ekdSDdw8qxKyxj1piv8oYzMd4fCjCpL+WDZtq7mdLErVZ92gH
-----END CERTIFICATE REQUEST-----",

}

# You just create the client with the parameters described above.
sepa_client = Sepa::Client.new(params)
puts sepa_client.inspect
#puts sepa_client.methods
puts sepa_client.errors.full_messages
# Response is created by triggering 'send_request' from client
response = sepa_client.send_request
puts response.inspect
# Response contains methods valid? and payload
# puts response.payload if response.valid?

# puts "\n\nHashes match in the response: #{response.hashes_match?}"
# puts "Signature is valid in the response: #{response.signature_is_valid?}"

# puts "\nHashes match in the application response: #{ar.hashes_match?}"
# puts "Signature is valid in the application response: #{ar.signature_is_valid?}"

# puts "\nSome info about response's certificate:\n" \

#   "Issuer: #{response.certificate.issuer}\n" \
#   "First day to use this certificate: #{response.certificate.not_before}\n" \
#   "Expires: #{response.certificate.not_after}"

# puts "\nSome info about application response's certificate:\n" \
#   "Issuer: #{ar.certificate.issuer}\n" \
#   "First day to use this certificate: #{ar.certificate.not_before}\n" \
#   "Expires: #{ar.certificate.not_after}"

