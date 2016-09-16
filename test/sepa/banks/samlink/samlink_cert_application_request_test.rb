require 'test_helper'

class SamlinkCertApplicationRequestTest < ActiveSupport::TestCase
  setup do
    @params = samlink_get_certificate_params
    @ar     = Sepa::SoapBuilder.new(@params).application_request
    @xml    = Nokogiri::XML(@ar.to_xml)
  end

  test "validates against schema" do
    assert_valid_against_schema 'samlink/CertApplicationRequest.xsd', @xml
  end
end
