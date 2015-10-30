require 'test_helper'

class OpCertApplicationRequestTest < ActiveSupport::TestCase
  include Sepa::Utilities

  setup do
    @op_get_certificate_params = op_get_certificate_params
    ar_cert                    = Sepa::SoapBuilder.new(@op_get_certificate_params).application_request
    @xml                       = Nokogiri::XML(ar_cert.to_xml)
  end

  test "schemas are unmodified" do
    sha1        = OpenSSL::Digest::SHA1.new
    cert_schema = File.read("#{SCHEMA_PATH}/op/CertApplicationRequest_200812.xsd")
    cert_digest = sha1.digest(cert_schema)
    assert_equal "jq7suQXu6STF7F5la67ZXoZGCNg=", encode(cert_digest).strip
  end

  test "initializes correctly" do
    assert Sepa::ApplicationRequest.new(@op_get_certificate_params)
  end

  test "raises argument error if command is not get certificate" do
    assert_raises ArgumentError do
      @op_get_certificate_params[:command] = :wrong_command
      ar                                   = Sepa::ApplicationRequest.new(@op_get_certificate_params)
      ar.get_as_base64
    end
  end

  test "customer id is set correctly" do
    assert_equal @xml.at_css("CustomerId").content, @op_get_certificate_params[:customer_id]
  end

  test "timestamp is set correctly" do
    timestamp = Time.strptime(@xml.at_css("Timestamp").content, '%Y-%m-%dT%H:%M:%S%z')
    assert timestamp <= Time.now && timestamp > (Time.now - 60), "Timestamp was not set correctly"
  end

  test "command is set correctly" do
    assert_equal @xml.at_css("Command").content, "GetCertificate"
  end

  test "environment is set correctly" do
    expected_environment = @op_get_certificate_params[:environment].upcase
    assert_equal expected_environment, @xml.at_css("Environment").content
  end

  test "software id is set correctly" do
    assert_equal @xml.at_css("SoftwareId").content, "Sepa Transfer Library version #{Sepa::VERSION}"
  end

  test "service is set correctly" do
    assert_equal "MATU", @xml.at_css("Service").content
  end

  test "content is set correctly" do
    assert_equal format_cert_request(@op_get_certificate_params[:signing_csr]), @xml.at_css("Content").content
  end

  test "hmac is not set" do
    refute @xml.at_css("HMAC"), "HMAC should not be set, but is #{@xml.at_css("HMAC")}"
  end

  test "validates against schema" do
    errors = []

    Dir.chdir(SCHEMA_PATH) do
      xsd = Nokogiri::XML::Schema(IO.read('op/CertApplicationRequest_200812.xsd'))
      xsd.validate(@xml).each do |error|
        errors << error
      end
    end

    assert errors.empty?, "The following schema validations failed:\n#{errors.join("\n")}"
  end
end
