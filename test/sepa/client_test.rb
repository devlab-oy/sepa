require 'test_helper'

class ClientTest < ActiveSupport::TestCase
  include Sepa::ErrorMessages

  def setup
    # Get params hashes from fixtures for different banks and for different request types
    @nordea_generic_params            = nordea_generic_params
    @nordea_get_certificate_params    = nordea_get_certificate_params
    @nordea_renew_certificate_params  = nordea_get_certificate_params
    @danske_create_certificate_params = danske_create_certificate_params
    @danske_renew_certificate_params  = danske_renew_cert_params
    @danske_generic_params            = danske_generic_params

    # Namespaces
    @cor = 'http://bxd.fi/CorporateFileService'
  end

  test "should initialize class" do
    assert Sepa::Client.new
  end

  test "correct banks are supported" do
    assert_equal [:danske, :nordea, :op, :samlink].sort, Sepa::Client::BANKS.sort
  end

  test "correct allowed commands for nordea" do
    c = Sepa::Client.new(bank: :nordea)

    commands = STANDARD_COMMANDS + [:get_certificate, :renew_certificate]

    assert_same_items commands, c.allowed_commands
  end

  test "correct allowed commands for op" do
    c = Sepa::Client.new(bank: :op)

    commands =
      STANDARD_COMMANDS -
      %i(get_user_info) +
      %i(
        get_certificate
        get_service_certificates
        renew_certificate
      )

    assert_same_items commands, c.allowed_commands
  end

  test "correct allowed commands for danske" do
    c = Sepa::Client.new(bank: :danske)

    commands = [
      STANDARD_COMMANDS - [:get_user_info],
      [:get_bank_certificate, :create_certificate, :renew_certificate],
    ].flatten

    assert_same_items commands, c.allowed_commands
  end

  test "correct allowed commands for samlink" do
    c = Sepa::Client.new(bank: :samlink)

    commands = [
      STANDARD_COMMANDS - [:get_user_info],
      [:get_certificate, :renew_certificate],
    ].flatten

    assert_same_items commands, c.allowed_commands
  end

  test "should initialize with attributes" do
    assert Sepa::Client.new @nordea_generic_params
  end

  test "should set attributes" do
    a = Sepa::Client.new
    assert a.attributes @nordea_generic_params
  end

  test "should be valid with required params" do
    sepa = Sepa::Client.new @danske_create_certificate_params
    assert sepa.valid?, sepa.errors.messages
  end

  test "should not be valid with invalid bank" do
    @nordea_generic_params[:bank] = :royal_bank_of_skopje
    sepa = Sepa::Client.new @nordea_generic_params
    refute sepa.valid?, sepa.errors.messages
  end

  test 'commands differ by bank' do
    @nordea_get_certificate_params[:bank] = :danske
    @nordea_get_certificate_params[:command] = :get_certificate
    sepa = Sepa::Client.new @nordea_get_certificate_params
    refute sepa.valid?, sepa.errors.messages
  end

  test "private keys are checked" do
    wrong_pks = ['Im not a key', :leppakerttu, nil]

    wrong_pks.each do |wrong_pk|
      @nordea_generic_params[:signing_private_key] = wrong_pk
      sepa = Sepa::Client.new @nordea_generic_params
      refute sepa.valid?, sepa.errors.messages
    end
  end

  test "certificates are checked" do
    wrong_certs = ['Im not a cert', 99, :leppakerttu, nil]

    wrong_certs.each do |wrong_cert|
      @nordea_generic_params[:own_signing_certificate] = wrong_cert
      sepa = Sepa::Client.new @nordea_generic_params
      refute sepa.valid?, sepa.errors.messages
    end
  end

  test "customer id is correct" do
    wrong_ids = ["a" * 17, nil]

    wrong_ids.each do |wrong_id|
      @nordea_generic_params[:customer_id] = wrong_id
      sepa = Sepa::Client.new @nordea_generic_params
      refute sepa.valid?, sepa.errors.messages
      assert_includes sepa.errors.messages.to_s, CUSTOMER_ID_ERROR_MESSAGE
    end
  end

  test "environment is checked" do
    wrong_envs = ["not proper", :protuction]

    wrong_envs.each do |wrong_env|
      @nordea_generic_params[:environment] = wrong_env
      sepa = Sepa::Client.new @nordea_generic_params
      refute sepa.valid?, sepa.errors.messages
      assert_includes sepa.errors.messages.to_s, ENVIRONMENT_ERROR_MESSAGE
    end
  end

  test 'environment defaults to production' do
    empty_environments = [nil, false, true]

    empty_environments.each do |empty_environment|
      @nordea_generic_params[:environment] = empty_environment
      sepa = Sepa::Client.new @nordea_generic_params
      assert sepa.environment == :production
      assert sepa.valid?
    end
  end

  test "status values are checked" do
    wrong_statuses = ["ready", 'steady', 5, :nipsu]

    wrong_statuses.each do |wrong_status|
      @nordea_generic_params[:command] = :download_file_list
      @nordea_generic_params[:status] = wrong_status
      sepa = Sepa::Client.new @nordea_generic_params
      refute sepa.valid?, sepa.errors.messages
    end
  end

  test 'target id is checked' do
    wrong_ids = ["ready" * 81, nil, false]
    @nordea_generic_params[:command] = :upload_file

    wrong_ids.each do |wrong_id|
      @nordea_generic_params[:target_id] = wrong_id
      sepa = Sepa::Client.new @nordea_generic_params
      refute sepa.valid?, sepa.errors.messages
      assert_includes sepa.errors.messages.to_s, TARGET_ID_ERROR_MESSAGE
    end
  end

  test "language values are valid" do
    wrong_langs = ["Joo", 7, :protuction]

    wrong_langs.each do |wrong_lang|
      @nordea_generic_params[:language] = wrong_lang
      sepa = Sepa::Client.new @nordea_generic_params
      refute sepa.valid?, sepa.errors.messages
    end
  end

  test "file type is checked" do
    wrong_types = ["kalle" * 36, nil, false]

    wrong_types.each do |wrong_type|
      [:upload_file, :download_file_list].each do |command|
        @nordea_generic_params[:command] = command
        @nordea_generic_params[:file_type] = wrong_type
        sepa = Sepa::Client.new @nordea_generic_params
        refute sepa.valid?, sepa.errors.messages
        assert_includes sepa.errors.messages.to_s, FILE_TYPE_ERROR_MESSAGE
      end
    end
  end

  test 'content is checked when command is upload file' do
    invalid_contents = [nil, false, true]

    invalid_contents.each do |invalid_content|
      @nordea_generic_params[:command] = :upload_file
      @nordea_generic_params[:content] = invalid_content
      sepa = Sepa::Client.new @nordea_generic_params
      refute sepa.valid?, sepa.errors.messages
      assert_includes sepa.errors.messages.to_s, CONTENT_ERROR_MESSAGE
    end
  end

  test 'file reference is required for download file' do
    invalid_file_references = [nil, false, true]

    invalid_file_references.each do |invalid_file_reference|
      @nordea_generic_params[:file_reference] = invalid_file_reference
      sepa = Sepa::Client.new @nordea_generic_params
      refute sepa.valid?, sepa.errors.messages
      assert_includes sepa.errors.messages.to_s, FILE_REFERENCE_ERROR_MESSAGE
    end
  end

  # # The response from savon will be the request to check that a proper request
  # # was made in the following four tests
  test "should_send_proper_request_with_nordea_get_user_info" do
    @nordea_generic_params[:command] = :get_user_info
    client = Sepa::Client.new(@nordea_generic_params)
    response = client.send_request

    assert response.doc.at_css('cor|getUserInfoin', cor: @cor)
    assert_valid_against_schema 'soap.xsd', response.doc
  end

  test "should_send_proper_request_with_nordea_download_file_list" do
    @nordea_generic_params[:command] = :download_file_list
    client = Sepa::Client.new(@nordea_generic_params)
    response = client.send_request

    assert response.doc.at_css('cor|downloadFileListin', cor: @cor)
    assert_valid_against_schema 'soap.xsd', response.doc
  end

  test "should_send_proper_request_with_nordea_download_file" do
    @nordea_generic_params[:command] = :download_file
    client = Sepa::Client.new(@nordea_generic_params)
    response = client.send_request

    assert response.doc.at_css('cor|downloadFilein', cor: @cor)
    assert_valid_against_schema 'soap.xsd', response.doc
  end

  test "should_send_proper_request_with_nordea_upload_file" do
    @nordea_generic_params[:command] = :upload_file
    client = Sepa::Client.new(@nordea_generic_params)
    response = client.send_request

    assert response.doc.at_css('cor|uploadFilein', cor: @cor)
    assert_valid_against_schema 'soap.xsd', response.doc
  end

  test 'should send proper request with nordea get certificate' do
    client = Sepa::Client.new(@nordea_get_certificate_params)
    response = client.send_request

    assert response.doc.at_css('cer|getCertificatein')
    assert_valid_against_schema 'soap.xsd', response.doc
  end

  test 'sends a proper request with nordea renew certificate' do
    client   = Sepa::Client.new(@nordea_renew_certificate_params)
    response = client.send_request

    assert response.doc.at('cer|getCertificatein')
    assert_valid_against_schema 'soap.xsd', response.doc
  end

  test 'should send proper request with danske download file list' do
    @danske_generic_params[:command] = :download_file_list
    client = Sepa::Client.new(@danske_generic_params)
    response = client.send_request

    assert_valid_against_schema 'soap.xsd', response.doc
  end

  test 'should send proper request with danske download file' do
    @danske_generic_params[:command] = :download_file
    client = Sepa::Client.new(@danske_generic_params)
    response = client.send_request

    assert_valid_against_schema 'soap.xsd', response.doc
  end

  test 'should send proper request with danske upload file' do
    client = Sepa::Client.new(@danske_generic_params)
    response = client.send_request

    assert_valid_against_schema 'soap.xsd', response.doc
  end

  test 'should send proper request with danske create certificate' do
    client = Sepa::Client.new(@danske_create_certificate_params)
    response = client.send_request

    assert_valid_against_schema 'soap.xsd', response.doc
  end

  test 'sends a proper request with danske renew certificate' do
    client   = Sepa::Client.new(@danske_renew_certificate_params)
    response = client.send_request

    assert response.doc.at('pkif|RenewCertificateIn', pkif: 'http://danskebank.dk/PKI/PKIFactoryService')
    assert_valid_against_schema 'soap.xsd', response.doc
  end

  test "signing csr is checked correctly with danske cert requests" do
    [
      @danske_create_certificate_params,
      @danske_renew_certificate_params,
    ].each do |params|
      params.delete(:signing_csr)

      sepa = Sepa::Client.new(params)
      refute sepa.valid?
      assert_includes sepa.errors.messages.to_s, SIGNING_CERT_REQUEST_ERROR_MESSAGE
    end
  end

  test "encryption csr is checked correctly with danske cert requests" do
    [
      @danske_create_certificate_params,
      @danske_renew_certificate_params,
    ].each do |params|
      params.delete(:encryption_csr)

      sepa = Sepa::Client.new(params)
      refute sepa.valid?
      assert_includes sepa.errors.messages.to_s, ENCRYPTION_CERT_REQUEST_ERROR_MESSAGE
    end
  end

  test "should_check_pin_with_create_certificate" do
    invalid_pins = [nil, false, true, ""]

    invalid_pins.each do |invalid_pin|
      @danske_create_certificate_params[:command] = :create_certificate
      @danske_create_certificate_params[:pin] = invalid_pin

      sepa = Sepa::Client.new(@danske_create_certificate_params)
      refute sepa.valid?
      assert_includes sepa.errors.messages.to_s, PIN_ERROR_MESSAGE
    end
  end

  test 'should check pin with get certificate' do
    invalid_pins = [nil, false, true]

    invalid_pins.each do |invalid_pin|
      @nordea_get_certificate_params[:pin] = invalid_pin

      sepa = Sepa::Client.new(@nordea_get_certificate_params)
      refute sepa.valid?
      assert_includes sepa.errors.messages.to_s, PIN_ERROR_MESSAGE
    end
  end

  test "should_check_encryption_cert_with_create_certificate" do
    @danske_create_certificate_params[:command] = :create_certificate
    @danske_create_certificate_params.delete(:bank_encryption_certificate)

    sepa = Sepa::Client.new(@danske_create_certificate_params)
    refute sepa.valid?
    assert_includes sepa.errors.messages.to_s, ENCRYPTION_CERT_ERROR_MESSAGE
  end

  test "response should be invalid on savon exception" do
    # Create an observer to fake sending requests to bank
    observer = Class.new do
      def notify(operation_name, builder, globals, locals)
        @operation_name = operation_name
        @builder = builder
        @globals = globals
        @locals  = locals
        HTTPI::Response.new(500, {}, 'THE ERROR!')
      end
    end.new

    Savon.observers << observer

    client = Sepa::Client.new @nordea_generic_params
    response = client.send_request

    refute response.valid?, response.errors.messages
    assert_includes response.errors.messages.to_s, "THE ERROR!"

    Savon.observers.pop
  end

  test 'encryption private key is checked when bank is danske' do
    @danske_generic_params.delete :encryption_private_key
    client = Sepa::Client.new @danske_generic_params
    refute client.valid?
  end

  test 'bank encryption certificate is checked when bank is danske' do
    @danske_generic_params.delete :bank_encryption_certificate
    client = Sepa::Client.new @danske_generic_params
    refute client.valid?
  end

  test 'presence of encryption private key is checked when bank is danske' do
    @danske_generic_params.delete :encryption_private_key
    client = Sepa::Client.new @danske_generic_params
    refute client.valid?
  end

  test 'validity of encryption private key is checked when bank is danske' do
    wrong_keys = [encode('kissa' * 1000), false]

    wrong_keys.each do |wrong_key|
      @danske_generic_params[:encryption_private_key] = wrong_key
      client = Sepa::Client.new @danske_generic_params
      refute client.valid?
      refute_empty client.errors.messages
    end
  end

  test 'validity of encryption certificate is checked when bank is danske' do
    @danske_generic_params[:bank_encryption_certificate] = encode('kissa' * 1000)
    client = Sepa::Client.new @danske_generic_params
    refute client.valid?
    refute_empty client.errors.messages
  end

  test 'signing csr is checked with nordea when command is get certificate' do
    @nordea_get_certificate_params[:signing_csr] = encode('kissa' * 1000)
    client = Sepa::Client.new @nordea_get_certificate_params

    refute client.valid?
    refute_empty client.errors.messages
  end

  test 'savon options can be passed to client and accessed' do
    client = Sepa::Client.new(@nordea_get_certificate_params)

    assert client.respond_to?(:savon_options)
    assert client.respond_to?(:savon_options=)

    client.savon_options = {
      globals: {
        ssl_verify_mode: :none,
      },
    }

    assert_nothing_raised { client.send_request }
  end
end
