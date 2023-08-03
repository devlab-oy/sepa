require 'test_helper'

class DanskeRenewCertApplicationRequestTest < ActiveSupport::TestCase
  setup do
    @params = danske_renew_cert_params

    # Convert the keys here since the conversion is usually done by the client and these tests
    # bypass the client
    @params[:own_signing_certificate] = x509_certificate(@params[:own_signing_certificate])
    @params[:signing_private_key]     = rsa_key(@params[:signing_private_key])

    @ar  = Sepa::ApplicationRequest.new(@params)
    @doc = @ar.to_nokogiri
  end

  test 'validates against schema' do
    assert_valid_against_schema 'danske_pki.xsd', @doc
  end

  test 'signature is calculated correctly' do
    sha1                  = OpenSSL::Digest::SHA1.new
    keys_path             = File.expand_path('../keys', __FILE__)
    private_key           = rsa_key(File.read("#{keys_path}/signing_key.pem"))
    canonicalization_mode = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0

    signed_info_node = @doc.at("dsig|SignedInfo", dsig: 'http://www.w3.org/2000/09/xmldsig#')
    actual_signature = encode(private_key.sign(sha1, signed_info_node.canonicalize(canonicalization_mode)))

    calculated_signature = @doc.at("dsig|SignatureValue", dsig: 'http://www.w3.org/2000/09/xmldsig#').content

    assert_equal actual_signature.gsub(/\s+/, ""), calculated_signature
  end
end
