require File.expand_path('../../test_helper.rb', __FILE__)

class ClientTest < MiniTest::Test
  def setup
    @wsdl_path = File.expand_path('../../../lib/sepa/wsdl/wsdl_nordea.xml',
                                  __FILE__)

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
      wsdl: @wsdl_path,
      content: Base64.encode64("Kurppa"),
      file_reference: "11111111A12006030329501800000014"
    }

    observer = Class.new {

      def notify(*)
        HTTPI::Response.new(200, { "Haisuli" => "Haiseva" }, "Vesinokkaelain")
      end

    }.new

    Savon.observers << observer
  end

  def test_should_initialize_with_proper_params
    assert Sepa::Client.new(@params)
  end

  def test_should_raise_error_if_wsdl_missing
    @params.delete(:wsdl)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_command_missing
    @params.delete(:command)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_private_key_missing
    @params.delete(:private_key)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_cert_missing
    @params.delete(:cert)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_customer_id_missing
    @params.delete(:customer_id)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_environment_missing
    @params.delete(:environment)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_target_id_missing
    @params.delete(:target_id)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_language_missing
    @params.delete(:language)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  # Temporary test to make sure that savon mocking is working
  def test_savon_mocking_works
    client = Sepa::Client.new(@params)
    response = client.send

    assert_equal response.http.code, 200
    assert_equal response.http.headers, 'Haisuli' => 'Haiseva'
    assert_equal response.http.body, 'Vesinokkaelain'
  end
end
