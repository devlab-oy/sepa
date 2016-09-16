require 'test_helper'

class SamlinkCertRequestSoapBuilderTest < ActiveSupport::TestCase
  setup do
    @params  = samlink_get_certificate_params
    @request = Sepa::SoapBuilder.new(@params)
    @xml     = Nokogiri::XML(@request.to_xml)
  end

  test "validates against schema" do
    assert_valid_against_schema 'soap.xsd', @xml
  end
end
