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

  test 'validates against ws security schema' do
    wsse    = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'
    ws_node = @doc.at('wsse|Security', 'wsse': wsse)
    ws_node = ws_node.to_xml
    ws_node = Nokogiri::XML(ws_node)

    assert_valid_against_schema 'oasis-200401-wss-wssecurity-secext-1.0.xsd', ws_node
  end
end
