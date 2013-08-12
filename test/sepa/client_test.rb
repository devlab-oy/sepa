require File.expand_path('../../test_helper.rb', __FILE__)

class ClientTest < MiniTest::Test
  def setup
    @schemas_path = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)

    wsdl_path = File.expand_path('../../../lib/sepa/wsdl/wsdl_nordea.xml',
                                 __FILE__)

    keys_path = File.expand_path('../nordea_test_keys', __FILE__)

    danske_keys_path = File.expand_path('../danske_test_keys', __FILE__)

    private_key = OpenSSL::PKey::RSA.new File.read "#{keys_path}/nordea.key"
    cert = OpenSSL::X509::Certificate.new File.read "#{keys_path}/nordea.crt"

    @params = get_params

    @certparams = get_cert_params

    @danskecertparams = get_danske_cert_params

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

  def test_should_get_error_if_key_gen_type_missing
    @danskecertparams.delete(:key_generator_type)
    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end

  def test_should_raise_error_with_wrong_bank
    @params[:bank] = :royal_bank_of_skopje
    assert_raises(ArgumentError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_with_wrong_command_when_bank_doesnt_support_the_command
    @certparams[:bank] = :danske
    @certparams[:command] = :get_certificate
    assert_raises(ArgumentError) { Sepa::Client.new(@certparams) }
  end

  def test_should_not_initialize_with_unsupported_danske_params
    @danskecertparams[:command] = :twiddle_thumbs
    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
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

  def test_should_raise_error_if_private_key_plain_is_wrong
    wrong_pks = ['Im not a key', :leppakerttu, nil]

    wrong_pks.each do |wrong_pk|
      @params[:private_key_plain] = wrong_pk
      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  def test_should_raise_error_if_cert_plain_file_is_wrong
    wrong_certs = ['Im not a cert', 99, :leppakerttu, nil]

    wrong_certs.each do |wrong_cert|
      @params[:cert_plain] = wrong_cert
      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  def test_should_raise_error_if_private_key_path_wrong
    wrong_pks = ['Im not a key']

    wrong_pks.each do |wrong_pk|
      @params[:private_key_path] = wrong_pk
      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  def test_should_raise_error_if_cert_path_wrong
    wrong_certs = ['Im not a cert', :leppakerttu]

    wrong_certs.each do |wrong_cert|
      @params[:cert_path] = wrong_cert
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

  def test_should_raise_error_if_status_wrong
    commands = [:download_file, :download_file_list]

    commands.each do |command|
      @params[:command] = command

      wrong_statuses = ["ready", 'steady', 5, :nipsu]

      wrong_statuses.each do |wrong_status|
        @params[:status] = wrong_status

        assert_raises(ArgumentError) { Sepa::Client.new(@params) }
      end
    end
  end

  def test_should_raise_error_if_target_id_wrong
    commands = [:download_file, :download_file_list, :upload_file]

    commands.each do |command|
      @params[:command] = command

      wrong_ids = ["ready"*81, nil]

      wrong_ids.each do |wrong_id|
        @params[:target_id] = wrong_id

        assert_raises(ArgumentError) { Sepa::Client.new(@params) }
      end
    end
  end

  def test_should_raise_error_if_language_wrong
    wrong_langs = ["Joo", 7, :protuction]

    wrong_langs.each do |wrong_lang|
      @params[:language] = wrong_lang

      assert_raises(ArgumentError) { Sepa::Client.new(@params) }
    end
  end

  def test_should_raise_error_if_file_type_wrong_or_missing
    commands = [:download_file, :download_file_list, :upload_file]

    commands.each do |command|
      @params[:command] = command

      wrong_types = ["kalle"*41, nil]

      wrong_types.each do |wrong_type|
        @params[:file_type] = wrong_type

        assert_raises(ArgumentError) { Sepa::Client.new(@params) }
      end
    end
  end

  def test_should_raise_error_if_content_missing
    @params[:command] = :upload_file
    @params.delete(:content)

    assert_raises(ArgumentError) { Sepa::Client.new(@params) }
  end

  # The response from savon will be the request to check that a proper request
  # was made in the following four tests
  def test_should_send_proper_request_with_get_user_info
    @params[:command] = :get_user_info
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

  def test_should_initialize_with_proper_cert_params
    assert Sepa::Client.new(@certparams)
  end

  def test_should_send_proper_request_with_get_certificate
    client = Sepa::Client.new(@certparams)
    response = client.send

    assert_equal response.body.keys[0], :get_certificatein

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(Nokogiri::XML(response.to_xml))
    end
  end

  def test_should_raise_error_if_cert_service_missing
    @certparams[:command] = :get_certificate
    @certparams.delete(:service)

    assert_raises(ArgumentError) { Sepa::Client.new(@certparams) }
  end

  def test_should_raise_error_if_signing_pkcs_plain_and_path_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:signing_cert_pkcs10_plain)
    @danskecertparams.delete(:signing_cert_pkcs10_path)

    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end

  def test_should_raise_error_if_encryption_pkcs_plain_and_path_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:encryption_cert_pkcs10_plain)
    @danskecertparams.delete(:encryption_cert_pkcs10_path)

    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end

  def test_should_raise_error_if_pin_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:pin)

    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end

  def test_should_raise_error_if_cert_plain_and_cert_path_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:cert_plain)
    @danskecertparams.delete(:cert_path)

    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end
end
