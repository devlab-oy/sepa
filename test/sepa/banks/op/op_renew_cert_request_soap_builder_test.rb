require 'test_helper'

class OpRenewCertRequestSoapBuilderTest < ActiveSupport::TestCase
  setup do
    @params = op_renew_certificate_params

    # Convert the keys here since the conversion is usually done by the client and these tests
    # bypass the client
    @params[:own_signing_certificate] = x509_certificate(@params[:own_signing_certificate])
    @params[:signing_private_key]     = rsa_key(@params[:signing_private_key])

    @doc = Nokogiri::XML(Sepa::SoapBuilder.new(@params).to_xml)
  end

  test "validates against schema" do
    assert_valid_against_schema 'soap.xsd', @doc
  end

  test 'application request is inserted properly' do
    ar_node = @doc.at("xmlns|ApplicationRequest", xmlns: 'http://mlp.op.fi/OPCertificateService')
    ar_doc  = Nokogiri::XML(decode(ar_node.content))

    assert ar_doc.respond_to?(:canonicalize)
    assert_equal @params[:customer_id], ar_doc.at_css("CustomerId").content
  end
end
