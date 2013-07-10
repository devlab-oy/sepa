require File.expand_path('../../test_helper.rb', __FILE__)

class ClientTest < MiniTest::Test
  def setup
    @schemas_path = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)

    wsdl_path = File.expand_path('../../../lib/sepa/wsdl/wsdl_nordea.xml',
                                 __FILE__)

    keys_path = File.expand_path('../nordea_test_keys', __FILE__)

    danske_keys_path = File.expand_path('../danske_test_keys', __FILE__)

    private_key = OpenSSL::PKey::RSA.new File.read "#{keys_path}/nordea.key"
    cert = OpenSSL::X509::Certificate.new File.read "#{keys_path}/nordea.crt"
    certplain = "-----BEGIN CERTIFICATE-----
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
    pkeyplain = "-----BEGIN PRIVATE KEY-----
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
csrplain = "-----BEGIN CERTIFICATE REQUEST-----
MIIBczCB3QIBADA0MRIwEAYDVQQDEwlEZXZsYWIgT3kxETAPBgNVBAUTCDExMTEx
MTExMQswCQYDVQQGEwJGSTCBnzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAo9wU
c2Ys5hSso4nEanbc+RIhL71aS6GBGiWAegXjhlyb6dpwigrZBFPw4u6UZV/Vq7Y7
Ku3uBq5rfZwk+lA+c/B634Eu0zWdI+EYfQxKVRrBrmhiGplKEtglHXbNmmMOn07e
LPUaB0Ipx/6h/UczJGBINdtcuIbYVu0r7ZfyWbUCAwEAAaAAMA0GCSqGSIb3DQEB
BQUAA4GBAIhh2o8mN4Byn+w1jdbhq6lxEXYqdqdh1F6GCajt2lQMUBgYP23I5cS/
Z+SYNhu8vbj52cGQPAwEDN6mm5yLpcXu40wYzgWyfStLXV9d/b4hMy9qLMW00Dzb
jo2ekdSDdw8qxKyxj1piv8oYzMd4fCjCpL+WDZtq7mdLErVZ92gH
-----END CERTIFICATE REQUEST-----"
    @params = {
      bank: :nordea,
      private_key_plain: pkeyplain,
      cert_plain: certplain,
      command: :get_user_info,
      customer_id: '11111111',
      environment: 'PRODUCTION',
      status: 'NEW',
      target_id: '11111111A1',
      language: 'FI',
      file_type: 'TITO',
      content: Base64.encode64("Kurppa"),
      file_reference: "11111111A12006030329501800000014"
    }

    @certparams = {
      bank: :nordea,
      command: :get_certificate,
      customer_id: '11111111',
      environment: 'TEST',
      pin: '1234567890',
      csr_plain: csrplain,
      service: 'service'
    }

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
      customer_id: 'ABC123',
      environment: 'customertest',
      key_generator_type: 'software',
      encryption_cert_pkcs10_plain: encryptpkcsplain,
      signing_cert_pkcs10_plain: signingpkcsplain,
      cert_plain: danskebankencryptplain,
      pin: '1234'
    }

    observer = Class.new {
      def notify(operation_name, builder, globals, locals)
        @operation_name = operation_name
        @builder = builder
        @globals = globals
        @locals  = locals

        HTTPI::Response.new(200,
                            { "Reponse is actually" => "the request, w0000t" },
                            locals[:xml])
      end
    }.new

    Savon.observers << observer
  end

  def test_should_get_error_if_key_gen_type_missing
    @danskecertparams.delete(:key_generator_type)

    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end

  def test_should_raise_error_with_wrong_bank
    @params[:bank] = :royal_bank_of_skopje
    assert_raises(ArgumentError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_with_wrong_command_when_bank_doesnt_support_the_command
    @certparams[:bank] = :danske
    @certparams[:command] = :get_certificate
    assert_raises(ArgumentError) { Sepa::Client.new(@certparams) }
  end

  def test_should_not_initialize_with_unsupported_danske_params
    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end

  def test_should_initialize_with_proper_params
    assert Sepa::Client.new(@params)
  end

  def test_should_give_proper_error_if_initialized_with_something_not_hash_like
    not_hashes = ['Merihevonsenkenka', 1, :verhokangas]

    not_hashes.each do |not_hash|
      assert_raises(ArgumentError) { Sepa::Client.new(not_hash) }
    end
  end

  def test_should_raise_error_if_private_key_plain_is_wrong
    # Fails until new way of testing is implemented for either pathed or plain text private key
    wrong_pks = ['Im not a key', 99, :leppakerttu, nil]

    wrong_pks.each do |wrong_pk|
      @params[:private_key_plain] = wrong_pk
      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  def test_should_raise_error_if_cert_plain_file_is_wrong
    # Fails until new way of testing is implemented for either pathed or plain text cert
    wrong_certs = ['Im not a cert', 99, :leppakerttu, nil]

    wrong_certs.each do |wrong_cert|
      @params[:cert_plain] = wrong_cert
      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  def test_should_raise_error_if_command_wrong_or_missing
    wrong_commands = ['string is not a command', 1337, :symbol_but_not_proper,
                      nil]

    wrong_commands.each do |wrong_command|
      @params[:command] = wrong_command

      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  def test_should_raise_error_if_customer_id_wrong_or_missing
    wrong_ids = ["I'm a way too long a string and probably also not valid", nil]

    wrong_ids.each do |wrong_id|
      @params[:customer_id] = wrong_id

      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  def test_should_raise_error_if_environment_wrong_or_missing
    wrong_envs = ["not proper", 5, :protuction, nil]

    wrong_envs.each do |wrong_env|
      @params[:environment] = wrong_env

      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  def test_should_raise_error_if_status_wrong
    commands = [:download_file, :download_file_list]

    commands.each do |command|
      @params[:command] = command

      wrong_statuses = ["ready", 'steady', 5, :nipsu]

      wrong_statuses.each do |wrong_status|
        @params[:status] = wrong_status

        assert_raises(ArgumentError) { Sepa::Client.new(@params) }
      end
    end
  end

  def test_should_raise_error_if_target_id_wrong
    commands = [:download_file, :download_file_list, :upload_file]

    commands.each do |command|
      @params[:command] = command

      wrong_ids = ["ready"*81, nil]

      wrong_ids.each do |wrong_id|
        @params[:target_id] = wrong_id

        assert_raises(ArgumentError) { Sepa::Client.new(@params) }
      end
    end
  end

  def test_should_raise_error_if_language_wrong
    wrong_langs = ["Joo", 7, :protuction]

    wrong_langs.each do |wrong_lang|
      @params[:language] = wrong_lang

      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  def test_should_raise_error_if_file_type_wrong_or_missing
    commands = [:download_file, :download_file_list, :upload_file]

    commands.each do |command|
      @params[:command] = command

      wrong_types = ["kalle"*41, nil]

      wrong_types.each do |wrong_type|
        @params[:file_type] = wrong_type

        assert_raises(ArgumentError) { Sepa::Client.new(@params) }
      end
    end
  end

  def test_should_raise_error_if_content_missing
    @params[:command] = :upload_file
    @params.delete(:content)

    assert_raises(ArgumentError) { Sepa::Client.new(@params) }
  end

  # The response from savon will be the request to check that a proper request
  # was made in the following four tests
  def test_should_send_proper_request_with_get_user_info
    client = Sepa::Client.new(@params)
    response = client.send

    assert_equal response.body.keys[0], :get_user_infoin

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(Nokogiri::XML(response.to_xml))
    end
  end

  def test_should_send_proper_request_with_download_file_list
    @params[:command] = :download_file_list
    client = Sepa::Client.new(@params)
    response = client.send

    assert_equal response.body.keys[0], :download_file_listin

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(Nokogiri::XML(response.to_xml))
    end
  end

  def test_should_send_proper_request_with_download_file
    @params[:command] = :download_file
    client = Sepa::Client.new(@params)
    response = client.send

    assert_equal response.body.keys[0], :download_filein

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(Nokogiri::XML(response.to_xml))
    end
  end

  def test_should_send_proper_request_with_upload_file
    @params[:command] = :upload_file
    client = Sepa::Client.new(@params)
    response = client.send

    assert_equal response.body.keys[0], :upload_filein

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(Nokogiri::XML(response.to_xml))
    end
  end

  def test_should_initialize_with_proper_cert_params
    assert Sepa::Client.new(@certparams)
  end

  def test_should_send_proper_request_with_get_certificate
    client = Sepa::Client.new(@certparams)
    response = client.send

    assert_equal response.body.keys[0], :get_certificatein

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(Nokogiri::XML(response.to_xml))
    end
  end

  def test_should_raise_error_if_cert_service_missing
    @certparams[:command] = :get_certificate
    @certparams.delete(:service)

    assert_raises(ArgumentError) { Sepa::Client.new(@certparams) }
  end

  def test_should_raise_error_if_signing_pkcs_plain_and_path_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:signing_cert_pkcs10_plain)
    @danskecertparams.delete(:signing_cert_pkcs10_path)

    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end

  def test_should_raise_error_if_encryption_pkcs_plain_and_path_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:encryption_cert_pkcs10_plain)
    @danskecertparams.delete(:encryption_cert_pkcs10_path)

    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end

  def test_should_raise_error_if_pin_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:pin)

    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end

  def test_should_raise_error_if_cert_plain_and_cert_path_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:cert_plain)
    @danskecertparams.delete(:cert_path)

    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end
end
