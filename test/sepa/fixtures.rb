def danske_generic_params
  keys_path = "#{ROOT_PATH}/test/sepa/banks/danske/keys"

  signing_private_key_path = "#{keys_path}/signing_key.pem"
  signing_private_key = File.read signing_private_key_path

  encryption_private_key_path = "#{keys_path}/enc_private_key.pem"
  encryption_private_key = File.read encryption_private_key_path

  signing_certificate_path = "#{keys_path}/own_signing_cert.pem"
  own_signing_certificate = File.read signing_certificate_path

  encryption_certificate_path = "#{keys_path}/own_enc_cert.pem"
  bank_encryption_certificate = File.read encryption_certificate_path

  {
    bank: :danske,
    signing_private_key: signing_private_key,
    encryption_private_key: encryption_private_key,
    command: :upload_file,
    customer_id: '360817',
    environment: 'test',
    bank_encryption_certificate: bank_encryption_certificate,
    own_signing_certificate: own_signing_certificate,
    language: 'FI',
    status: 'ALL',
    target_id: 'DABAFIHH',
    file_type: 'pain.001.001.02',
    content: encode('kissa'),
    file_reference: '11111111A12006030329501800000014',
  }
end

def nordea_generic_params
  own_signing_certificate = "-----BEGIN CERTIFICATE-----
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
-----END CERTIFICATE-----"
  signing_private_key = "-----BEGIN PRIVATE KEY-----
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
-----END PRIVATE KEY-----"

  {
    bank: :nordea,
    signing_private_key: signing_private_key,
    own_signing_certificate: own_signing_certificate,
    command: :download_file,
    customer_id: '11111111',
    environment: 'production',
    status: 'NEW',
    target_id: '11111111A1',
    language: 'FI',
    file_type: 'TITO',
    content: encode("haisuli"),
    file_reference: "11111111A12006030329501800000014"
  }
end

def nordea_get_certificate_params
  signing_csr = "-----BEGIN CERTIFICATE REQUEST-----
MIIBczCB3QIBADA0MRIwEAYDVQQDEwlEZXZsYWIgT3kxETAPBgNVBAUTCDExMTEx
MTExMQswCQYDVQQGEwJGSTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAo9wU
c2Ys5hSso4nEanbc+RIhL71aS6GBGiWAegXjhlyb6dpwigrZBFPw4u6UZV/Vq7Y7
Ku3uBq5rfZwk+lA+c/B634Eu0zWdI+EYfQxKVRrBrmhiGplKEtglHXbNmmMOn07e
LPUaB0Ipx/6h/UczJGBINdtcuIbYVu0r7ZfyWbUCAwEAAaAAMA0GCSqGSIb3DQEB
BQUAA4GBAIhh2o8mN4Byn+w1jdbhq6lxEXYqdqdh1F6GCajt2lQMUBgYP23I5cS/
Z+SYNhu8vbj52cGQPAwEDN6mm5yLpcXu40wYzgWyfStLXV9d/b4hMy9qLMW00Dzb
jo2ekdSDdw8qxKyxj1piv8oYzMd4fCjCpL+WDZtq7mdLErVZ92gH
-----END CERTIFICATE REQUEST-----"

  {
    bank: :nordea,
    command: :get_certificate,
    customer_id: '11111111',
    environment: 'test',
    signing_csr: signing_csr,
    pin: '1234567890'
  }
end

def op_get_certificate_params
  signing_csr = "-----BEGIN CERTIFICATE REQUEST-----
MIICZzCCAU8CAQAwIjELMAkGA1UEBhMCRkkxEzARBgNVBAMTCjEwMDAwMTA1ODMw
ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDFIQFuGnCPMLquHTfXj+ef
31w+7qILkGsPcf24udpDy2AmP0PNrPAdB4S/gW9UXqR4ZiJPnEQIP6y/OGDxd6la
0T/wNIVbLIJlPP5YgEZ1HYaV+6CsOa/n5PhXyC8Uy9BK9Txew8MqLakYvOfzKNuD
oi9Fdfj7NjT2OgeyL5UMpzPvFxunbOwNT7QEGdZ4+Um5pJOvNWTuUGqYq1J9MAyU
2PPBsvQ3fOOxR5t8QnMlbxC+JZkaaO14ELi4riAaFW0Q/MbwKCEXSX6Erb3F+o8l
DDqITxfgBRr0crhYicLy7aMZzMJHqXoaSHZHUZBpCxRhnlgykCcErLJxC3S8m0rT
AgMBAAGgADANBgkqhkiG9w0BAQUFAAOCAQEAkDsDiweg4oi52zSZZvGTlbEf3Mly
rTKXNToBZ6n5DrChsc6Rk8VySVpFFOiiLGKwB9YHzNIipWDZ8CVXPPNZAtWJMPPW
sJjgx2EMUxlimGKW6Ipd7PL2jQA5tpEao9CNdVPSrm5fs4Wd40A1JWJeUGKi4KKJ
ZZn3Um8Lu5n6nAkT+v2jXI94nPFckMMuEpVml/hdT8zg4EuC6ilo9OEBiOdMzVO1
5pK4Dp6ZHeTKoyUiwnVMssT5kCAovLYrmd0/qRVZ1JeEKN9t20APfpHVeu0WfWSE
GuNaWLWOhkOqCtAdNkSGeq/ZKbjYHolGo5FBQqdJnuz0r3I5nfLUNAHXNg==
-----END CERTIFICATE REQUEST-----"

  {
    bank:        :op,
    command:     :get_certificate,
    customer_id: '1000010583',
    environment: 'test',
    signing_csr: signing_csr,
    pin:         '2251401483958635'
  }
end

def danske_get_bank_cert_params
  {
      bank: :danske,
      command: :get_bank_certificate,
      bank_root_cert_serial: '1111110002',
      customer_id: '360817',
  }
end

def danske_cert_params
  encryptpkcs = "-----BEGIN CERTIFICATE REQUEST-----
MIICZjCCAU4CAQAwITESMBAGA1UEAxMJRGV2bGFiIE95MQswCQYDVQQGEwJGSTCC
ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKN2ceFGw+i4wAyg6WApu7/h
5Rpl8tp+QRX1eLbmftYpf6bbzj+JwspWNST/s8p8enGBRrK+HkNT8ayj7ZSubJwx
g/bAn+ewxk64A984hiMqd0GMJgwFcWhGpHhwH9QiqA5CAQYXY0T1fs2UXf1mIJ1Z
675yGRhU03ZyQgyIjhdTmXLznCluSLeIGypXPi7DCfHP5w0a6Dfpy31fowqi7n9A
gyoQ6JZuuXHAdEoQpNmxgpp9gBwxs9U+yBmDaBAvvB0DY3+0kMRFCn2oyCuQw5C4
mRo+0eOO+kA8Svd2bLXmcbe6js/5SgjvkHvvCgIqi9J6aPiJo0XCrLsB6BjQbpsC
AwEAAaAAMA0GCSqGSIb3DQEBBQUAA4IBAQAXepnKWQWTCiTKXhuT+e52n0/x5YHd
bLB8nelPpyMf0hiNeoUdzNTZoMM2OArtzvOhh5HWZ32GbjR/RDCy+kMfAGDm/tlB
/4uJNcDotMFF+MUsEAHVrAUpZh5n00mBeYDl7m098VnAEayxUxJHbQMYY1J1QdTl
M62i5c2v3sNJlDlT4GidRtoGW9KAID2oCdOL94krWpwLAZDP4wLwG7ACCbOx3rST
f9gDE6jFUn7ONuiiYvOBAqjwckDpyOH+vx3WkZH4cwdcp4KVeLnjJzlJZaw7yTIo
z8BKfQ26LmOO/S4CFe3Vzq6FRNKl3D4nvCu06WoMi5tAAEi57tk05B32
-----END CERTIFICATE REQUEST-----"

  signingpkcs = "-----BEGIN CERTIFICATE REQUEST-----
MIICZjCCAU4CAQAwITESMBAGA1UEAxMJRGV2bGFiIE95MQswCQYDVQQGEwJGSTCC
ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAK3yym5CztvmJCxbzhy6tOph
wzamimFKlJt88cG0VLzwAh0EiAhFz9Yj/39n1HywL+4xOLizIAup794MzLBDs3TH
OAZe7iZSrb5y4PMh5l9jwhXLPu7/tkqswcvMtstI5HZGqEqdw0kAT0BuKJBXdo+e
8nOCVsiMPhrtk5ovLY54vWMzwfAQJeBkxbr1LH6Ib4k7IlsysKpQt7+VqQcTc/lL
IC+MnVfmKDA0qTXFKQsZC2hO353cu9ZfjdrnKpo5gutcPJRu+TBNS8HJNkI+3pNM
MTGPvweeY461tzgOpeSzL+FkmRFSWksOmPol1Q4DDZryYHaLDv7q6lELNDxEwQ8C
AwEAAaAAMA0GCSqGSIb3DQEBBQUAA4IBAQAIw3tbNWTsayBm4bUzugNKCFreayTo
5npG3JUiA+n5jIdj3egqSXwxkXSJ5tdXcv0xqsFkV0wq3l5wEaeG7Jd7vLD6FX2y
MbtE49PHHcLwcY0U94qBj6qEleRwebGfyKwpMb2M90cAf3V/5IjZUJfvYyjOBQUT
H6Xhm3JG9g7AScHhFcM8r6PhmzcL1FubYBPTcUBuotDBYc4lbql7sbww/u8OyWvl
aIFd+oiwXGSYB7L8Fqg469jeIf0QtOZUtUEGOJWjM4JjTy+NnVmsj0jszMbuBZBW
7wOrp+GMBUZ9/vaY/zr7nvJTfvKz7CJQOgADeh/0imZqhIYfVKIpJxR5
-----END CERTIFICATE REQUEST-----"

  danskebankencrypt = "-----BEGIN CERTIFICATE-----
MIIEATCCAumgAwIBAgIFAQjv8bMwDQYJKoZIhvcNAQELBQAwgZgxEDAOBgNVBAMT
B0RCR1JPT1QxCzAJBgNVBAYTAkRLMRMwEQYDVQQHEwpDb3BlbmhhZ2VuMRAwDgYD
VQQIEwdEZW5tYXJrMRowGAYDVQQKExFEYW5za2UgQmFuayBHcm91cDEaMBgGA1UE
CxMRRGFuc2tlIEJhbmsgR3JvdXAxGDAWBgNVBAUTDzYxMTI2MjI4MTExMDAwMjAe
Fw0xMjA4MDEwMDAwMDBaFw0xNDEwMzEwMDAwMDBaMIGYMRAwDgYDVQQDEwdEUENS
WVBUMQswCQYDVQQGEwJESzETMBEGA1UEBxMKQ29wZW5oYWdlbjEQMA4GA1UECBMH
RGVubWFyazEaMBgGA1UEChMRRGFuc2tlIEJhbmsgR3JvdXAxGjAYBgNVBAsTEURh
bnNrZSBCYW5rIEdyb3VwMRgwFgYDVQQFEw82MTEyNjIyODQ5MTAwMDMwggEgMA0G
CSqGSIb3DQEBAQUAA4IBDQAwggEIAoIBAQC/kHrOvHOueBsit9drxIHpaD7mXINy
pXS/l9PbbOZ0lZKVEfW9gtG8xk9XggsPXHJMF/PXpG6mveXvPu9WW/XpryAUqGfv
YsC7Px3ixaJb2EMOL+2mJYd0v5HKg5RuYkQ82k3K01hMNEGYs0OotjNVAimQcTLt
VPDGBjK5BUAiwady9LpI6afo7roJWnRmsvSvinDgBqswnfCvUfSfM8cZyhnLLC2u
j1kBHAD/5xpllmS3aq1M8LqFkBYcCE5PdPmFWhGUumZ/Y5qLjDgcPMAPvUaKLqOs
h22jvPCZ0pm17eV0bSQzWe5e0zkgCYAepuFRazSlkJQYBdS47Mp68dY5AgEDo1Iw
UDAfBgNVHSMEGDAWgBSE+uW/3pFJZt/FilLDs7ezIBzHbTAdBgNVHQ4EFgQUP6wH
VNOmznu212c08M3oeYjeXW4wDgYDVR0PAQH/BAQDAgQwMA0GCSqGSIb3DQEBCwUA
A4IBAQAvJBfPug+ixGL/zWUnKMweV80atZXMjHJEn4mOE+iUkCNONLImMMt6MXJy
snJViL1gL5xMrka6A62PLLsVkl79kxDDbzXMPfGt5/mB9L7CMpyzaID0acDii3rs
ZwT3Wxpnate6wowN4zpmXgpCpTDGbxjuVRiOArsjQblerhfxnD/UAieZ1IWozIAN
s6SVms/TuOB+bODUr06ITxBkDJhizOJxjsXRIAtwZvvrH4qGjJz5qFcPb3nz4Txw
swU8X6yvbtqF+q4aAKPA6ZydnGZFQSoSzNJtcF28T1ItxEHN3+xyQqXpTgFviiuL
277LaAl9YUFFnSgeh7GiFitWJPfD
-----END CERTIFICATE-----"

  {
    bank: :danske,
    command: :create_certificate,
    customer_id: 'ABC123',
    environment: 'test',
    encryption_cert_pkcs10: encryptpkcs,
    signing_cert_pkcs10: signingpkcs,
    enc_cert: danskebankencrypt,
    pin: '1234',
    language: 'EN',
    file_type: 'TITO',
    file_reference: '12314',
    target_id: 'Danske FI',
    status: 'NEW',
  }
end

def danske_create_certificate_params
  encryption_csr = "-----BEGIN CERTIFICATE REQUEST-----
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

  signing_csr = "-----BEGIN CERTIFICATE REQUEST-----
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

  bank_encryption_certificate = File.read "#{DANSKE_TEST_KEYS_PATH}own_enc_cert.pem"

  {
      bank: :danske,
      bank_encryption_certificate: bank_encryption_certificate,
      command: :create_certificate,
      customer_id: '360817',
      environment: 'test',
      encryption_csr: encryption_csr,
      signing_csr: signing_csr,
      pin: '1234',
  }
end
