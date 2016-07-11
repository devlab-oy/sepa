require 'test_helper'

class DanskeCertificateApplicationRequestTest < ActiveSupport::TestCase
  setup do
    @cs_params = danske_create_certificate_params
    @cs_ar     = Sepa::ApplicationRequest.new(@cs_params)
  end

  test 'should set environment to customertest when test in parameters' do
    environment_node = @cs_ar.to_nokogiri.at('tns|Environment')

    assert_equal 'customertest', environment_node.content
  end
end
