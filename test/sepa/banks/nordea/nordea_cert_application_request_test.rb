require 'test_helper'

class NordeaCertApplicationRequestTest < ActiveSupport::TestCase
  include Sepa::Utilities

  def setup
    @nordea_get_certificate_params = nordea_get_certificate_params
    ar_cert = Sepa::SoapBuilder.new(@nordea_get_certificate_params).application_request
    @xml = Nokogiri::XML(ar_cert.to_xml)
  end

  def test_schemas_are_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    cert_schema = File.read("#{SCHEMA_PATH}/cert_application_request.xsd")
    cert_digest = sha1.digest(cert_schema)
    assert_equal encode(cert_digest).strip, "sFwy9Tj+cERTdcmaGhm8WpmJBH4="
  end

  def test_should_initialize_with_only_get_certificate_params
    assert Sepa::ApplicationRequest.new(@nordea_get_certificate_params)
  end

  def test_should_get_argument_errors_unless_command_is_get_certificate
    assert_raises(ArgumentError) do
      @nordea_get_certificate_params[:command] = :wrong_command
      ar = Sepa::ApplicationRequest.new(@nordea_get_certificate_params)
      ar.get_as_base64
    end
  end

  def test_should_have_customer_id_set
    assert_equal @xml.at_css("CustomerId").content, @nordea_get_certificate_params[:customer_id]
  end

  def test_should_have_timestamp_set_properly
    timestamp = Time.strptime(@xml.at_css("Timestamp").content, '%Y-%m-%dT%H:%M:%S%z')
    assert timestamp <= Time.now && timestamp > (Time.now - 60), "Timestamp was not set correctly"
  end

  def test_should_have_command_set_when_get_certificate
    assert_equal @xml.at_css("Command").content, "GetCertificate"
  end

  def test_should_have_environment_set_and_upcase
    expected_environment = @nordea_get_certificate_params[:environment].upcase
    assert_equal expected_environment, @xml.at_css("Environment").content
  end

  test 'should have software id set' do
    assert_equal @xml.at_css("SoftwareId").content, "Sepa Transfer Library version #{Sepa::VERSION}"
  end

  test 'should have service set' do
    assert_equal @xml.at_css('Service').content, ''
  end

  test 'should have content set' do
    assert_equal @xml.at_css('Content').content, format_cert_request(@nordea_get_certificate_params[:signing_csr])
  end

  test 'should have hmac set' do
    assert_equal @xml.at_css('HMAC').content,
                 hmac(@nordea_get_certificate_params[:pin], csr_to_binary(@nordea_get_certificate_params[:signing_csr]))
  end

  def test_should_validate_against_schema
    assert_valid_against_schema 'cert_application_request.xsd', @xml
  end
end
