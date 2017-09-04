require 'test_helper'

class OpRenewCertApplicationRequestTest < ActiveSupport::TestCase
  setup do
    @params = op_renew_certificate_params

    # Convert the keys here since the conversion is usually done by the client and these tests
    # bypass the client
    @params[:own_signing_certificate] = x509_certificate(@params[:own_signing_certificate])
    @params[:signing_private_key]     = rsa_key(@params[:signing_private_key])

    @doc = Nokogiri::XML(Sepa::SoapBuilder.new(@params).application_request.to_xml)
  end

  test "validates against schema" do
    assert_valid_against_schema 'op/CertApplicationRequest_200812.xsd', @doc
  end

  test "content is set correctly" do
    assert_equal format_cert_request(@params[:signing_csr]), @doc.at_css("Content").content
  end

  test 'digest is calculated correctly' do
    calculated_digest = @doc.at("xmlns|DigestValue", xmlns: 'http://www.w3.org/2000/09/xmldsig#').content

    # Remove signature for calculating digest
    @doc.at("xmlns|Signature", xmlns: 'http://www.w3.org/2000/09/xmldsig#').remove

    # Calculate digest
    sha1          = OpenSSL::Digest::SHA1.new
    actual_digest = encode(sha1.digest(@doc.canonicalize))

    # And then make sure the two are equal
    assert_equal actual_digest.strip, calculated_digest.strip
  end
end
