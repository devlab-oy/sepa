require 'test_helper'

class NordeaCertApplicationRequestTest < ActiveSupport::TestCase

  def setup
    @nordea_generic_params = nordea_cert_params
    ar_cert = Sepa::SoapBuilder.new(@nordea_generic_params).ar
    @xml = Nokogiri::XML(ar_cert.to_xml)
  end

  def test_schemas_are_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    cert_schema = File.read("#{SCHEMA_PATH}/cert_application_request.xsd")
    cert_digest = sha1.digest(cert_schema)
    assert_equal Base64.encode64(cert_digest).strip, "sFwy9Tj+cERTdcmaGhm8WpmJBH4="
  end

  def test_should_initialize_with_only_get_certificate_params
    assert Sepa::ApplicationRequest.new(@nordea_generic_params)
  end

  def test_should_get_argument_errors_unless_command_is_get_certificate
    assert_raises(ArgumentError) do
      @nordea_generic_params[:command] = :wrong_command
      ar = Sepa::ApplicationRequest.new(@nordea_generic_params)
      xml = ar.get_as_base64
    end
  end

  def test_should_have_customer_id_set
    assert_equal @xml.at_css("CustomerId").content, @nordea_generic_params[:customer_id]
  end

  def test_should_have_timestamp_set_properly
    timestamp = Time.strptime(@xml.at_css("Timestamp").content, '%Y-%m-%dT%H:%M:%S%z')
    assert timestamp <= Time.now && timestamp > (Time.now - 60), "Timestamp was not set correctly"
  end

  def test_should_have_command_set_when_get_certificate
    assert_equal @xml.at_css("Command").content, "GetCertificate"
  end

  def test_should_have_environment_set
    assert_equal @xml.at_css("Environment").content, @nordea_generic_params[:environment]
  end

  def test_should_validate_against_schema
    Dir.chdir(SCHEMA_PATH) do
      xsd = Nokogiri::XML::Schema(IO.read('cert_application_request.xsd'))
      assert xsd.valid?(@xml)
    end
  end

end
