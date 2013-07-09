require File.expand_path('../../test_helper.rb', __FILE__)

class CertApplicationRequestTest < MiniTest::Test
  def setup
    @schemapath = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)
    @templatepath = File.expand_path('../../../lib/sepa/xml_templates/application_request',__FILE__)
    @keyspath = File.expand_path('../nordea_test_keys', __FILE__)

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

  # The params hash is populated with the data that is needed for gem to function
  @params = {
    bank: :nordea,
    command: :get_certificate,
    customer_id: '11111111',
    environment: 'TEST',
    csr_plain: csrplain,
    pin: '1234567890',
    # Selected service (For testing: service, For real: ISSUER)
    service: 'service'
  }

  @ar_cert = Sepa::SoapBuilder.new(@params).get_ar_as_base64
  @xml = Nokogiri::XML(Base64.decode64(@ar_cert))
  end

  def test_that_xml_template_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new

    get_certificate_template = File.read("#{@templatepath}/get_certificate.xml")

    digest = Base64.encode64(sha1.digest(get_certificate_template)).strip

    assert_equal digest, "mpoY4dd4XW5HskkoRxqtVEM+Tts="
  end

  def test_schemas_are_unmodified
    sha1 = OpenSSL::Digest::SHA1.new

    cert_schema = File.read(
    "#{@schemapath}/cert_application_request.xsd")

    cert_digest = sha1.digest(cert_schema)

    assert_equal Base64.encode64(cert_digest).strip,"sFwy9Tj+cERTdcmaGhm8WpmJBH4="
  end

  def test_should_initialize_with_only_get_certificate_params
    assert Sepa::ApplicationRequest.new(@params)
  end

  def test_should_get_argument_errors_unless_command_is_get_certificate
    assert_raises(ArgumentError) do
      @params[:command] = :wrong_command
      ar = Sepa::ApplicationRequest.new(@params)
      xml = ar.get_as_base64
    end
  end

  def test_should_have_customer_id_set
    assert_equal @xml.at_css("CustomerId").content, @params[:customer_id]
  end

  def test_should_have_timestamp_set_properly
    timestamp = Time.strptime(@xml.at_css("Timestamp").content,
    '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= Time.now && timestamp > (Time.now - 60),
    "Timestamp was not set correctly"
  end

  def test_should_have_command_set_when_get_certificate
    assert_equal @xml.at_css("Command").content, "GetCertificate"
  end

  def test_should_have_environment_set
    assert_equal @xml.at_css("Environment").content, @params[:environment]
  end

  def test_should_have_service_set
    assert_equal @xml.at_css("Service").content, @params[:service]
  end

  def test_should_validate_against_schema
    Dir.chdir(@schemapath) do
      xsd = Nokogiri::XML::Schema(IO.read('cert_application_request.xsd'))
      assert xsd.valid?(@xml)
    end
  end
end