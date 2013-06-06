require File.expand_path('../../test_helper.rb', __FILE__)

class ClientTest < MiniTest::Test
  def setup
    @schemas_path = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)

    wsdl_path = File.expand_path('../../../lib/sepa/wsdl/wsdl_nordea.xml',
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
      wsdl: wsdl_path,
      content: Base64.encode64("Kurppa"),
      file_reference: "11111111A12006030329501800000014"
    }

    observer = Class.new {
      def notify(operation_name, builder, globals, locals)
        @operation_name = operation_name
        @builder = builder
        @globals = globals
        @locals  = locals

        HTTPI::Response.new(200,
                            { "Reponse is actually" => "the request, w0000t" },
                            locals[:xml])
      end
    }.new

    Savon.observers << observer
  end

  def test_should_initialize_with_proper_params
    assert Sepa::Client.new(@params)
  end

  def test_should_give_proper_error_if_initialized_with_something_not_hash_like
    not_hashes = ['Merihevonsenkenka', 1, :verhokangas]

    not_hashes.each do |not_hash|
      assert_raises(ArgumentError) { Sepa::Client.new(not_hash) }
    end
  end

  def test_should_raise_error_if_target_id_missing
    @params.delete(:target_id)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_language_missing
    @params.delete(:language)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_private_key_in_wrong_format_or_missing
    wrong_pks = ['Im not a key', 99, :leppakerttu, nil]

    wrong_pks.each do |wrong_pk|
      @params[:private_key] = wrong_pk
      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  def test_should_raise_error_if_cert_in_wrong_format_or_missing
    wrong_certs = ['Im not a cert', 99, :leppakerttu, nil]

    wrong_certs.each do |wrong_cert|
      @params[:cert] = wrong_cert
      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  def test_should_raise_error_if_wsdl_in_wrong_format_or_missing
    wrong_wsdls = ['not quite wsdl', 99, :leppakerttu, nil]

    wrong_wsdls.each do |wrong_wsdl|
      @params[:wsdl] = wrong_wsdl

      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  def test_should_raise_error_if_command_wrong_or_missing
    wrong_commands = ['string is not a command', 1337, :symbol_but_not_proper,
                      nil]

    wrong_commands.each do |wrong_command|
      @params[:command] = wrong_command

      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  def test_should_raise_error_if_customer_id_wrong_or_missing
    wrong_ids = ["I'm a way too long a string and probably also not valid", nil]

    wrong_ids.each do |wrong_id|
      @params[:customer_id] = wrong_id

      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  def test_should_raise_error_if_environment_wrong_or_missing
    wrong_envs = ["not proper", 5, :protuction, nil]

    wrong_envs.each do |wrong_env|
      @params[:environment] = wrong_env

      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  # The response from savon will be the request to check that a proper request
  # was made in the following four tests
  def test_should_send_proper_request_with_get_user_info
    client = Sepa::Client.new(@params)
    response = client.send

    assert_equal response.body.keys[0], :get_user_infoin

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(Nokogiri::XML(response.to_xml))
    end
  end

  def test_should_send_proper_request_with_download_file_list
    @params[:command] = :download_file_list
    client = Sepa::Client.new(@params)
    response = client.send

    assert_equal response.body.keys[0], :download_file_listin

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(Nokogiri::XML(response.to_xml))
    end
  end

  def test_should_send_proper_request_with_download_file
    @params[:command] = :download_file
    client = Sepa::Client.new(@params)
    response = client.send

    assert_equal response.body.keys[0], :download_filein

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(Nokogiri::XML(response.to_xml))
    end
  end

  def test_should_send_proper_request_with_upload_file
    @params[:command] = :upload_file
    client = Sepa::Client.new(@params)
    response = client.send

    assert_equal response.body.keys[0], :upload_filein

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(Nokogiri::XML(response.to_xml))
    end
  end
end
