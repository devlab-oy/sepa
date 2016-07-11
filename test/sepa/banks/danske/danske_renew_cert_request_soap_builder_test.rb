require 'test_helper'

class DanskeRenewCertRequestSoapBuilderTest < ActiveSupport::TestCase
  setup do
    @params = danske_renew_cert_params

    # Convert the keys here since the conversion is usually done by the client and these tests
    # bypass the client
    @params[:own_signing_certificate] = x509_certificate(@params[:own_signing_certificate])
    @params[:signing_private_key]     = rsa_key(@params[:signing_private_key])

    soap_builder = Sepa::SoapBuilder.new(@params)
    @doc         = Nokogiri::XML(soap_builder.to_xml)
  end

  test "validates against schema" do
    assert_valid_against_schema 'soap.xsd', @doc
  end
end
