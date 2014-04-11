require 'test_helper'

class ClientTest < ActiveSupport::TestCase

  def setup
    @schemas_path = File.expand_path('../../../lib/sepa/xml_schemas', __FILE__)
    wsdl_path = File.expand_path('../../../lib/sepa/wsdl/wsdl_nordea.xml', __FILE__)
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

  test "should initialize class" do
    assert Sepa::Client.new
  end

  test "should initialize with attributes" do
    assert Sepa::Client.new @params
  end

  test "should set attributes" do
    a = Sepa::Client.new
    assert a.attributes @params
  end

  test "should be valid with required params" do
    sepa = Sepa::Client.new @danskecertparams
    assert sepa.valid?
  end

  test "not valid if invalid bank" do
    @params[:bank] = :royal_bank_of_skopje
    sepa = Sepa::Client.new @params
    refute sepa.valid?, sepa.errors.messages
  end

  test "banks supported commands" do
    @certparams[:bank] = :danske
    @certparams[:command] = :get_certificate
    sepa = Sepa::Client.new @certparams
    refute sepa.valid?, sepa.errors.messages
  end

  def test_should_raise_error_if_private_key_plain_is_wrong
    wrong_pks = ['Im not a key', :leppakerttu, nil]

    wrong_pks.each do |wrong_pk|
      @params[:private_key_plain] = wrong_pk
      refute Sepa::Client.new(@params).valid?
    end
  end

  def test_should_raise_error_if_cert_plain_file_is_wrong
    wrong_certs = ['Im not a cert', 99, :leppakerttu, nil]

    wrong_certs.each do |wrong_cert|
      @params[:cert_plain] = wrong_cert
      refute Sepa::Client.new(@params).valid?
    end
  end

  def test_should_raise_error_if_private_key_path_wrong
    wrong_pks = ['Im not a key']

    wrong_pks.each do |wrong_pk|
      @params[:private_key_path] = wrong_pk
      refute Sepa::Client.new(@params).valid?
    end
  end

  def test_should_raise_error_if_cert_path_wrong
    wrong_certs = ['Im not a cert', :leppakerttu]

    wrong_certs.each do |wrong_cert|
      @params[:cert_path] = wrong_cert
      refute Sepa::Client.new(@params).valid?
    end
  end

  def test_should_raise_error_if_command_wrong_or_missing
    wrong_commands = ['string is not a command', 1337, :symbol_but_not_proper,
                      nil]

    wrong_commands.each do |wrong_command|
      @params[:command] = wrong_command

      refute Sepa::Client.new(@params).valid?
    end
  end

  def test_should_raise_error_if_customer_id_wrong_or_missing
    wrong_ids = ["I'm a way too long a string and probably also not valid", nil]

    wrong_ids.each do |wrong_id|
      @params[:customer_id] = wrong_id

      refute Sepa::Client.new(@params).valid?
    end
  end

  def test_should_raise_error_if_environment_wrong_or_missing
    wrong_envs = ["not proper", 5, :protuction, nil]

    wrong_envs.each do |wrong_env|
      @params[:environment] = wrong_env

      refute Sepa::Client.new(@params).valid?
    end
  end

  def test_should_raise_error_if_status_wrong
    commands = [:download_file, :download_file_list]

    commands.each do |command|
      @params[:command] = command

      wrong_statuses = ["ready", 'steady', 5, :nipsu]

      wrong_statuses.each do |wrong_status|
        @params[:status] = wrong_status

        refute Sepa::Client.new(@params).valid?
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

        refute Sepa::Client.new(@params).valid?
      end
    end
  end

  def test_should_raise_error_if_language_wrong
    wrong_langs = ["Joo", 7, :protuction]

    wrong_langs.each do |wrong_lang|
      @params[:language] = wrong_lang

      refute Sepa::Client.new(@params).valid?
    end
  end

  def test_should_raise_error_if_file_type_wrong_or_missing
    commands = [:download_file, :download_file_list, :upload_file]

    commands.each do |command|
      @params[:command] = command

      wrong_types = ["kalle"*41, nil]

      wrong_types.each do |wrong_type|
        @params[:file_type] = wrong_type

        refute Sepa::Client.new(@params).valid?
      end
    end
  end

  def test_should_raise_error_if_content_missing
    @params[:command] = :upload_file
    @params.delete(:content)

    refute Sepa::Client.new(@params).valid?
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

    refute Sepa::Client.new(@certparams).valid?
  end

  def test_should_raise_error_if_signing_pkcs_plain_and_path_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:signing_cert_pkcs10_plain)
    @danskecertparams.delete(:signing_cert_pkcs10_path)

    refute Sepa::Client.new(@danskecertparams).valid?
  end

  def test_should_raise_error_if_encryption_pkcs_plain_and_path_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:encryption_cert_pkcs10_plain)
    @danskecertparams.delete(:encryption_cert_pkcs10_path)

    refute Sepa::Client.new(@danskecertparams).valid?
  end

  def test_should_raise_error_if_pin_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:pin)

    refute Sepa::Client.new(@danskecertparams).valid?
  end

  def test_should_raise_error_if_cert_plain_and_cert_path_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:cert_plain)
    @danskecertparams.delete(:cert_path)

    refute Sepa::Client.new(@danskecertparams).valid?
  end
end
