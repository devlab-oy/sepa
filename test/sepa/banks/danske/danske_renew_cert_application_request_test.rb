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
end
