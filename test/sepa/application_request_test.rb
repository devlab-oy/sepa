require_relative '../test_helper'

class TestApplicationRequest < MiniTest::Unit::TestCase
  def setup
    keys_path = File.expand_path('../nordea_test_keys', __FILE__)

    @params = {
      private_key: "#{keys_path}/nordea.key",
      cert: "#{keys_path}/nordea.crt",
      command: :download_file,
      customer_id: '11111111',
      environment: 'PRODUCTION',
      status: 'NEW',
      target_id: '11111111A1',
      language: 'FI',
      file_type: 'TITO',
      wsdl: 'sepa/wsdl/wsdl_nordea.xml',
      content: Base64.encode64("haisuli"),
      file_reference: "11111111A12006030329501800000014"
    }
  end

  def test_ar_should_initialize_with_proper_params
    Sepa::ApplicationRequest.new(@params)
  end

  def test_load_should_return_XML_doc_with_proper_command
    commands = [:get_user_info, :download_file, :download_file_list, :upload_file]

    commands.each do |command|
      @params[:command] = command
      ar = Sepa::ApplicationRequest.new(@params)
      assert ar.load_template(@params[:command]).respond_to?(:canonicalize)
    end
  end

  def test_load_should_raise_arg_err_when_bad_command
    ar = Sepa::ApplicationRequest.new(@params)
    assert_raises ArgumentError do
      ar.load_template(:wrongcommand)
    end
  end
end