require 'test_helper'

class NordeaRenewCertApplicationRequestTest < ActiveSupport::TestCase
  setup do
    @params = nordea_renew_certificate_params

    # Convert the keys here since the conversion is usually done by the client and these tests
    # bypass the client
    @params[:own_signing_certificate] = x509_certificate(@params[:own_signing_certificate])
    @params[:signing_private_key]     = rsa_key(@params[:signing_private_key])

    application_request = Sepa::SoapBuilder.new(@params).application_request
    @doc                = Nokogiri::XML(application_request.to_xml)
  end

  test "validates against schema" do
    assert_valid_against_schema 'cert_application_request.xsd', @doc
  end

  test "customer id is set correctly" do
    assert_equal @params[:customer_id], @doc.at_css("CustomerId").content
  end

  test "timestamp is set correctly" do
    timestamp = Time.strptime(@doc.at_css("Timestamp").content, '%Y-%m-%dT%H:%M:%S%z')
    assert timestamp <= Time.now && timestamp > (Time.now - 60), "Timestamp was not set correctly"
  end

  test "environment is set correctly" do
    assert_equal @params[:environment].upcase, @doc.at_css("Environment").content
  end

  test "software id is set correctly" do
    assert_equal "Sepa Transfer Library #{Sepa::VERSION}", @doc.at_css("SoftwareId").content
  end

  test "service is set correctly" do
    assert_equal "service", @doc.at_css("Service").content
  end

  test "content is set correctly" do
    assert_equal format_cert_request(@params[:signing_csr]), @doc.at_css("Content").content
  end

  test 'digest is calculated correctly' do
    calculated_digest = @doc.at("xmlns|DigestValue", xmlns: 'http://www.w3.org/2000/09/xmldsig#').content

    # Remove signature for calculating digest
    @doc.at("xmlns|Signature", xmlns: 'http://www.w3.org/2000/09/xmldsig#').remove

    # Calculate digest
    digest = OpenSSL::Digest::SHA256.new
    actual_digest = encode(digest.digest(@doc.canonicalize))

    # And then make sure the two are equal
    assert_equal actual_digest.strip, calculated_digest.strip
  end
end
