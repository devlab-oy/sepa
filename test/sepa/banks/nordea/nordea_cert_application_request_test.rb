require 'test_helper'

class NordeaCertApplicationRequestTest < ActiveSupport::TestCase
  include Sepa::Utilities

  def setup
    @get_cert_params = nordea_cert_params
    ar_cert = Sepa::SoapBuilder.new(@get_cert_params).application_request
    @xml = Nokogiri::XML(ar_cert.to_xml)
  end

  def test_schemas_are_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    cert_schema = File.read("#{SCHEMA_PATH}/cert_application_request.xsd")
    cert_digest = sha1.digest(cert_schema)
    assert_equal encode(cert_digest).strip, "sFwy9Tj+cERTdcmaGhm8WpmJBH4="
  end

  def test_should_initialize_with_only_get_certificate_params
    assert Sepa::ApplicationRequest.new(@get_cert_params)
  end

  def test_should_get_argument_errors_unless_command_is_get_certificate
    assert_raises(ArgumentError) do
      @get_cert_params[:command] = :wrong_command
      ar = Sepa::ApplicationRequest.new(@get_cert_params)
      ar.get_as_base64
    end
  end

  def test_should_have_customer_id_set
    assert_equal @xml.at_css("CustomerId").content, @get_cert_params[:customer_id]
  end

  def test_should_have_timestamp_set_properly
    timestamp = Time.strptime(@xml.at_css("Timestamp").content, '%Y-%m-%dT%H:%M:%S%z')
    assert timestamp <= Time.now && timestamp > (Time.now - 60), "Timestamp was not set correctly"
  end

  def test_should_have_command_set_when_get_certificate
    assert_equal @xml.at_css("Command").content, "GetCertificate"
  end

  def test_should_have_environment_set
    assert_equal @xml.at_css("Environment").content, @get_cert_params[:environment]
  end

  test 'should have software id set' do
    assert_equal @xml.at_css("SoftwareId").content, "Sepa Transfer Library version #{Sepa::VERSION}"
  end

  test 'should have service set' do
    assert_equal @xml.at_css('Service').content, @get_cert_params[:service]
  end

  test 'should have content set' do
    assert_equal @xml.at_css('Content').content, format_cert_request(@get_cert_params[:csr])
  end

  test 'should have hmac set' do
    assert_equal @xml.at_css('HMAC').content,
                 hmac(@get_cert_params[:pin], csr_to_binary(@get_cert_params[:csr]))
  end

  def test_should_validate_against_schema
    Dir.chdir(SCHEMA_PATH) do
      xsd = Nokogiri::XML::Schema(IO.read('cert_application_request.xsd'))
      assert xsd.valid?(@xml)
    end
  end

end
