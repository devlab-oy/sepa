require File.expand_path('../../test_helper.rb', __FILE__)

class DanskeGetBankCertTest < MiniTest::Test
  def setup
    @params = {
      bank: :danske,
      target_id: 'Danske FI',
      command: :get_bank_certificate,
      bank_root_cert_serial: '1111110002',
      customer_id: '360817'
    }
  end

  def test_should_initialize_request_with_proper_params
    assert Sepa::SoapBuilder.new(@params).to_xml
  end

  def test_should_not_initialize_with_improper_params
    @params = "kissa"
    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params)
    end
  end

  def test_should_get_error_if_bank_missing
    @params.delete(:bank)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params)
    end
  end

  def test_should_get_error_if_command_missing
    @params.delete(:command)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params)
    end
  end

  def test_should_get_error_if_customer_id_missing
    @params.delete(:customer_id)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params)
    end
  end

  def test_should_get_error_if_target_id_missing
    @params.delete(:target_id)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params)
    end
  end

  def test_should_get_error_if_bank_root_cert_cerial_missing
    @params.delete(:bank_root_cert_serial)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params)
    end
  end
end
