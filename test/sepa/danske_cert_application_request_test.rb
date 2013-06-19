require File.expand_path('../../test_helper.rb', __FILE__)

class DanskeCertRequestTest < MiniTest::Test
  def setup
    @schemapath = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)
    @templatepath = File.expand_path('../../../lib/sepa/xml_templates/application_request',__FILE__)
    @danske_keys_path = File.expand_path('../danske_test_keys', __FILE__)

    reqid = SecureRandom.random_number(1000).to_s<<SecureRandom.random_number(1000).to_s

    @danskecertparams = {
      bank: :danske,
      command: :create_certificate,
      wsdl: File.expand_path('../../../lib/sepa/wsdl/wsdl_danske_cert.xml',__FILE__),
      request_id: reqid,
      customer_id: 'ABC123',
      environment: 'customertest',
      key_generator_type: 'software',
      encryption_cert_pkcs10: OpenSSL::X509::Request.new(File.read ("#{@danske_keys_path}/encryption_pkcs.csr")),
      signing_cert_pkcs10: OpenSSL::X509::Request.new(File.read ("#{@danske_keys_path}/signing_pkcs.csr")),
      cert: OpenSSL::X509::Certificate.new(File.read ("#{@danske_keys_path}/danskeroot.pem")),
      pin: '1234'
    }

    @ar_cert = Sepa::ApplicationRequest.new(@danskecertparams)

    @xml = Nokogiri::XML(Base64.decode64(@ar_cert.get_as_base64))
  end

  # def test_that_xml_template_is_unmodified
  #   sha1 = OpenSSL::Digest::SHA1.new

  #   get_certificate_template = File.read("#{@templatepath}/get_certificate.xml")

  #   digest = Base64.encode64(sha1.digest(get_certificate_template)).strip

  #   assert_equal digest, "mpoY4dd4XW5HskkoRxqtVEM+Tts="
  # end

  # def test_schemas_are_unmodified
  #   sha1 = OpenSSL::Digest::SHA1.new

  #   cert_schema = File.read(
  #   "#{@schemapath}/danske_pki.xsd")

  #   cert_digest = sha1.digest(cert_schema)
  #   puts cert_digest
  #   assert_equal Base64.encode64(cert_digest).strip,"sFwy9Tj+cERTdcmaGhm8WpmJBH4="
  # end

  def test_should_initialize_with_only_create_certificate_params
    assert Sepa::ApplicationRequest.new(@danskecertparams)
  end

  # def test_should_get_key_errors_unless_command_is_get_certificate
  #   assert_raises(KeyError) do
  #     @danskecertparams[:command] = :wrong_command
  #     ar = Sepa::ApplicationRequest.new(@danskecertparams)
  #     xml = ar.get_as_base64
  #   end
  # end

  # def test_should_have_customer_id_set
  #   assert_equal @xml.at_css("CustomerId").content, @danskecertparams[:customer_id]
  # end

  # def test_should_have_timestamp_set_properly
  #   timestamp = Time.strptime(@xml.at_css("Timestamp").content,
  #   '%Y-%m-%dT%H:%M:%S%z')

  #   assert timestamp <= Time.now && timestamp > (Time.now - 60),
  #   "Timestamp was not set correctly"
  # end

  # def test_should_have_command_set_when_get_certificate
  #   assert_equal @xml.at_css("Command").content, "GetCertificate"
  # end

  # def test_should_have_environment_set
  #   assert_equal @xml.at_css("Environment").content, @danskecertparams[:environment]
  # end

  # def test_should_have_service_set
  #   assert_equal @xml.at_css("Service").content, @danskecertparams[:service]
  # end

  # def test_should_have_hmac_set
  #   assert_equal @xml.at_css("HMAC").content, Base64.encode64(@danskecertparams[:hmac]).chop
  # end

  # def test_should_have_content_set
  #   assert_equal @xml.at_css("Content").content, Base64.encode64(@danskecertparams[:content])
  # end

  # def test_should_validate_against_schema
  #   Dir.chdir(@schemapath) do
  #     xsd = Nokogiri::XML::Schema(IO.read('danske_pki.xsd'))
  #     assert xsd.valid?(@xml)
  #   end
  # end
end