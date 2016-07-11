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

  test 'signature is calculated correctly' do
    sha1        = OpenSSL::Digest::SHA1.new
    private_key = rsa_key(@params.fetch(:signing_private_key))

    added_signature = @doc.at("dsig|SignatureValue", dsig: 'http://www.w3.org/2000/09/xmldsig#').content

    signed_info_node = @doc.at("dsig|SignedInfo", dsig: 'http://www.w3.org/2000/09/xmldsig#')
    signed_info_node = signed_info_node.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
    actual_signature = encode(private_key.sign(sha1, signed_info_node)).gsub(/\s+/, "")

    assert_equal actual_signature, added_signature
  end
end
