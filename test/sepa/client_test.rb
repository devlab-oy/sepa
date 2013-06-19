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

    @params = {
      bank: :nordea,
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
    # Test pin number for HMAC seal key
    testpin = '1234567890'

    # Open Certificate Signing Request PKCS#10
    testcert = OpenSSL::X509::Request.new(File.read ("#{keys_path}/testcert.csr"))

    # Generate HMAC seal (SHA1 hash) with pin as key and PKCS#10 as message
    hmacseal = OpenSSL::HMAC.digest('sha1',testpin,testcert.to_der)

    # Assign the generated PKCS#10 to as payload (goes to Content element)
    payload = testcert.to_der

    # Assign the calculated HMAC seal as hmac (goes to HMAC element)
    hmac = hmacseal

    @certparams = {
      bank: :nordea,
      command: :get_certificate,
      customer_id: '11111111',
      environment: 'TEST',
      wsdl: File.expand_path('../../../lib/sepa/wsdl/wsdl_nordea_cert.xml',__FILE__),
      content: payload,
      hmac: hmac,
      service: 'service'
    }

    reqid = SecureRandom.random_number(1000).to_s<<SecureRandom.random_number(1000).to_s

    @danskecertparams = {
      bank: :danske,
      command: :create_certificate,
      wsdl: File.expand_path('../../../lib/sepa/wsdl/wsdl_danske_cert.xml',__FILE__),
      request_id: reqid,
      customer_id: 'ABC123',
      environment: 'customertest',
      key_generator_type: 'software',
      encryption_cert_pkcs10: OpenSSL::X509::Request.new(File.read ("#{danske_keys_path}/encryption_pkcs.csr")),
      signing_cert_pkcs10: OpenSSL::X509::Request.new(File.read ("#{danske_keys_path}/signing_pkcs.csr")),
      cert: OpenSSL::X509::Certificate.new(File.read ("#{danske_keys_path}/danskeroot.pem")),
      pin: '1234'
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

  def test_should_raise_error_with_wrong_bank
    @params[:bank] = :royal_bank_of_skopje
    assert_raises(ArgumentError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_with_wrong_command_when_bank_doesnt_support_the_command
    @certparams[:bank] = :danske
    @certparams[:command] = :get_certificate
    assert_raises(ArgumentError) { Sepa::Client.new(@certparams) }
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
    invalid_wsdl_path = File.expand_path('../test_files/invalid.wsdl',
                                         __FILE__)
    wrong_wsdls = [invalid_wsdl_path, 99, :leppakerttu, nil]

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

  def test_should_raise_error_if_cert_content_missing
    @certparams[:command] = :get_certificate
    @certparams.delete(:content)

    assert_raises(ArgumentError) { Sepa::Client.new(@certparams) }
  end

  def test_should_raise_error_if_cert_service_missing
    @certparams[:command] = :get_certificate
    @certparams.delete(:service)

    assert_raises(ArgumentError) { Sepa::Client.new(@certparams) }
  end

  def test_should_raise_error_if_cert_hmac_missing
    @certparams[:command] = :get_certificate
    @certparams.delete(:hmac)

    assert_raises(ArgumentError) { Sepa::Client.new(@certparams) }
  end

  def test_should_raise_error_if_signing_pkcs_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:signing_cert_pkcs10)

    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end

  def test_should_raise_error_if_encryption_pkcs_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:encryption_cert_pkcs10)

    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end

  def test_should_raise_error_if_pin_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:pin)

    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end

  def test_should_raise_error_if_cert_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:cert)

    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end

  def test_should_raise_error_if_request_id_not_integer_with_create_certificate
    @danskecertparams[:request_id] = "LOL I'm not a number"

    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end

  def test_should_raise_error_if_request_id_missing_with_create_certificate
    @danskecertparams[:command] = :create_certificate
    @danskecertparams.delete(:request_id)

    assert_raises(ArgumentError) { Sepa::Client.new(@danskecertparams) }
  end
end
