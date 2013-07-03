require File.expand_path('../../test_helper.rb', __FILE__)

class DanskeGenericSoapBuilderTest < MiniTest::Test
  def setup
    @schemapath = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)
    @templatepath = File.expand_path('../../../lib/sepa/xml_templates/soap',__FILE__)
    @danske_keys_path = File.expand_path('../danske_test_keys', __FILE__)
    danskesigning = "-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAvTnADLhlBL5Rdh7ckCeVueT+a77DwLymGO/PQJAUnOiCOA3h
dEPzg2ruKk9VgC5+ADTXDD4HIxYO0LB0l1hNTr0GhIbjGI4HLgBSlE1lS/v9rWy8
kQvFVBBysh3oo3aW27AqSGIUSZzHdOaf0vVmCM69aoHZ3rNHR4RoXA0nqisxBYKb
SepKSJ+BdIEthbgzOz5ybHY6CCIEU+TIbCEkhACXFk52hmId2ODmjnK9pF6EOyJ3
CMD8jOksjrb4E9ylChsX135jVqBWoyv49mkzCW7abhkgEB8Ap2nBp27Cm+nFGElW
co5gKwdEKjrkA2B/Hz6KoceR6OydaaZnUI7T5QIDAQABAoIBADNUoSZSNwUMY6i5
QnfQZStiVSoBO7Ti9+O32e7Xpt/RqtFt4oTZkgtKTIUptDXrZr7Dlrp5cRIxf59Y
3qfXilEbsdLtjFky3fu6lqwoOpxcJTqQTq7CFKtzMsnilyMQnmfF6BJumLZHU0wA
68YcT6t/+Z4Uz3c8Bs/9uRmPb/0W9qkWhH35JKtlFyN2g6nyKMCpYoll+FNun3nr
e6gqZ9lNbqWOAnf2hfZWIKXLHxh9Eko/kQQYzo1Y0bwJ9v5nbqpxpXn77Ys9eL63
Z7gQDVoYhaOVBzWWvp7bDQ0RlJ5dliWwfqSy7l5/u7/yuzcuozsE4/zsuGQEcgve
b721MhkCgYEA69tYh6QdlQtRq9SRmEe16X2UoWLN+tLNvAqdQxDqbwE0R8JxlW4z
gMpmM58L49aNQA50485jLZJaGwmK6vRpb9IBKB6iB94q20DtB4t1VNNQU3RtzbMQ
cdvJ+ocftflqaRMgAtKDbdeDtYxaG27g6Jz+yw8fq6krWaSIwoChHFcCgYEAzWLh
9+9yEPVlEW8CodIvhbCdeRnklgw/TZs6tg/B+99mN0QDeG/c2jbxBcOZ0DgksAn5
/bvhh1oRSOsZLDE9+ILjtTThbs6c4U2QyQxgvTRzX/NEHwid8rxk04mBOQtpYMD0
Y1yDg+qnJl3Zev6+DGQB9WbthJuOX/XWfEn/LCMCgYAxYhnlPK2c+WO+UKGzesBS
BSNLrz5lmCHPj4Fh+3a6i0wBAmt52DscakR/5ns81z13/g7na91EO3J2Wsclbsts
yFHJrrBKaXAbvDpk7ARDIIOfFa+v9CArVtOxiv1OwsxO99wp+x3dr9Q5/QsY11xs
GAMZTS9aZ+9Vs6eW4gvZvQKBgQCOEalHTJ01d9mKfqRudSqkKnAzNaL129DqCMdK
6ol/hZ95+RUBeTdmxnxgRVYfPsa58py3VAAEFVxBeUY3WHSKc1e5n7OUZ10DSBkv
yN0d46svIuHrKZXAM2r3HHWDlQ42fCJQnMzoMiefFWn7dzzU61SjgKgpg0Svwii0
XqcgywKBgAuj8hccUY5e5yRUGAqXrBfFCJN53ftkBaVtV0nqxJ2jXwIEqYCVohuM
gnUi1U8K+UAVu7JQJG1VUBEDcKFN2p/47KdpBx3calcurRmNL8Ual2ANPMC55RUD
11qQJynyu37oWB74v3VByP38tYy6tWmHUg55fMbjUtKW2AHdIXV5
-----END RSA PRIVATE KEY-----"
    danskebankencryptplain = "-----BEGIN CERTIFICATE-----
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
    reqid = SecureRandom.random_number(1000).to_s<<SecureRandom.random_number(1000).to_s

    @danskecertparams = {
      bank: :danske,
      target_id: 'Danske FI',
      language: 'EN',
      command: :download_file,
      request_id: reqid,
      customer_id: 'ABC123',
      environment: 'customertest',
      key_generator_type: 'software',
      private_key_plain: danskesigning,
      cert_plain: danskebankencryptplain,
      pin: '1234',
    }

    @certrequest = Sepa::SoapBuilder.new(@danskecertparams)

    @xml = Nokogiri::XML(@certrequest.to_xml_unencrypted_generic)
  end

  def test_should_initialize_request_with_proper_params
    assert Sepa::SoapBuilder.new(@danskecertparams).to_xml
  end

  def test_should_fail_if_language_missing
    @danskecertparams.delete(:language)
    assert_raises(KeyError) do
      Sepa::SoapBuilder.new(@danskecertparams).to_xml
    end
  end

  def test_should_fail_if_target_id_missing
    @danskecertparams.delete(:target_id)
    assert_raises(KeyError) do
      Sepa::SoapBuilder.new(@danskecertparams).to_xml
    end
  end

end