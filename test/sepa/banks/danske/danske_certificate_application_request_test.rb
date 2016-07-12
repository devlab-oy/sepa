require 'test_helper'

class DanskeCertificateApplicationRequestTest < ActiveSupport::TestCase
  setup do
    @params = danske_create_certificate_params
    @ar     = Sepa::ApplicationRequest.new(@params)
  end

  test 'environment is set to customertest when test in parameters' do
    environment_node = @ar.to_nokogiri.at('tns|Environment')

    assert_equal 'customertest', environment_node.content
  end
end
