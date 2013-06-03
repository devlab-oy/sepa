require File.expand_path('../../test_helper.rb', __FILE__)

class ClientTest < MiniTest::Test
  def setup
    keys_path = File.expand_path('../nordea_test_keys', __FILE__)

    private_key = OpenSSL::PKey::RSA.new File.read "#{keys_path}/nordea.key"
    cert = OpenSSL::X509::Certificate.new File.read "#{keys_path}/nordea.crt"

    @params = {
      private_key: private_key,
      cert: cert,
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
  end

  def test_should_initialize_with_proper_params
    assert Sepa::Client.new(@params)
  end

  def test_should_raise_error_if_wsdl_missing
    @params.delete(:wsdl)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end
end
