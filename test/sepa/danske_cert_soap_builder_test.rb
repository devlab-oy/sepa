require File.expand_path('../../test_helper.rb', __FILE__)

class DanskeCertSoapBuilderTest < MiniTest::Test
  def setup
    @schemapath = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)
    @templatepath = File.expand_path('../../../lib/sepa/xml_templates/soap',__FILE__)
    @danske_keys_path = File.expand_path('../danske_test_keys', __FILE__)

    reqid = SecureRandom.random_number(1000).to_s<<SecureRandom.random_number(1000).to_s
encryptpkcsplain = "-----BEGIN CERTIFICATE REQUEST-----
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
    signingpkcsplain = "-----BEGIN CERTIFICATE REQUEST-----
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
    @danskecertparams = {
      bank: :danske,
      command: :create_certificate,
      request_id: reqid,
      customer_id: 'ABC123',
      environment: 'customertest',
      key_generator_type: 'software',
      encryption_cert_pkcs10_plain: encryptpkcsplain,
      signing_cert_pkcs10_plain: signingpkcsplain,
      cert_plain: danskebankencryptplain,
      pin: '1234'
    }

    @certrequest = Sepa::SoapBuilder.new(@danskecertparams)

    @xml = Nokogiri::XML(@certrequest.to_xml_unencrypted)
  end

  def test_that_get_certificate_soap_template_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    template = File.read("#{@templatepath}/create_certificate.xml")
    digest = Base64.encode64(sha1.digest(template)).strip
    assert_equal digest, "OpPHtB1oqAmj2N7R0iD31MrApy0="
  end

  def test_should_initialize_with_proper_params
    assert Sepa::SoapBuilder.new(@danskecertparams)
  end

  def test_should_fail_with_wrong_command
    @danskecertparams.delete(:command)

    assert_raises(ArgumentError) { Sepa::SoapBuilder.new(@danskecertparams) }
  end

  def test_request_should_find_xmlenc_structure_when_request_encrypted
    xml = Nokogiri::XML(@certrequest.to_xml)

    xml.remove_namespaces!
    ar_node = xml.xpath("//EncryptedData").first

    assert ar_node.respond_to?(:canonicalize)
    assert_equal ar_node.at_css("EncryptionMethod")["Algorithm"], "http://www.w3.org/2001/04/xmlenc#tripledes-cbc"
  end

  def test_should_get_error_if_command_missing
    @danskecertparams.delete(:command)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@danskecertparams)
    end
  end

  def test_should_get_error_if_customer_id_missing
    @danskecertparams.delete(:customer_id)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@danskecertparams)
    end
  end

  def test_should_load_correct_template_with_get_certificate
    @danskecertparams[:command] = :create_certificate
    xml = Nokogiri::XML(Sepa::SoapBuilder.new(@danskecertparams).to_xml_unencrypted)

    assert xml.xpath('//tns:CreateCertificateRequest', 'tns' => 'http://danskebank.dk/PKI/PKIFactoryService/elements').first, "Path/namespace not found"
  end

  def test_should_raise_error_if_command_not_correct
    @danskecertparams[:command] = :wrong_command
    assert_raises(ArgumentError) do
      soap = Sepa::SoapBuilder.new(@danskecertparams).to_xml
    end
  end

  def test_timestamp_is_set_correctly
    timestamp_node = @xml.xpath(
      "//tns:Timestamp", 'tns' => 'http://danskebank.dk/PKI/PKIFactoryService/elements'
    ).first

    timestamp = Time.strptime(timestamp_node.content, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= Time.now && timestamp > (Time.now - 60)
  end

  def test_request_id_is_set_correctly
    request_id_node = @xml.xpath(
      "//tns:RequestId", 'tns' => 'http://danskebank.dk/PKI/PKIFactoryService/elements'
    ).first

    request_id = request_id_node.content.to_i

    assert request_id.kind_of?(Integer), "Request id should be a number"
    assert request_id != 0, "Request id can't be 0"
  end

  def test_should_validate_against_schema
    Dir.chdir(@schemapath) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(@xml)
    end
  end
end