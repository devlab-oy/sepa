require File.expand_path('../../test_helper.rb', __FILE__)

class SoapRequestTest < MiniTest::Unit::TestCase
  def setup
    keys_path = File.expand_path('../nordea_test_keys', __FILE__)

    @params = {
      private_key: "#{keys_path}/nordea.key",
      cert: "#{keys_path}/nordea.crt",
      command: :get_user_info,
      customer_id: '11111111',
      environment: 'PRODUCTION',
      status: 'NEW',
      target_id: '11111111A1',
      language: 'FI',
      file_type: 'TITO',
      wsdl: 'sepa/wsdl/wsdl_nordea.xml',
      content: Base64.encode64("Kurppa"),
      file_reference: "11111111A12006030329501800000014"
    }

    @soap_request = Sepa::SoapRequest.new(@params)
  end

  def test_should_initialize_with_proper_params
    assert Sepa::SoapRequest.new(@params)
  end
end