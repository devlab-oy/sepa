require 'test_helper'

class DanskeCertificateApplicationRequestTest < ActiveSupport::TestCase
  setup do
    @danske_create_certificate_params = danske_create_certificate_params
@danske_create_certificate_params[:environment] = :test
@danske_create_certificate_application_request    =
        Sepa::ApplicationRequest.new @danske_create_certificate_params
  end

  test 'should set environment to customertest when test in parameters' do
    environment_node =
        @danske_create_certificate_application_request.to_nokogiri.at('tns|Environment')
    assert_equal environment_node.content, 'customertest'
  end
end
