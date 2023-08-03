require 'test_helper'

class NordeaResponseTest < ActiveSupport::TestCase
  include Sepa::Utilities

  setup do
    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/dfl.xml"),
      command: :download_file_list,
    }
    @dfl = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/dfl_sha256.xml"),
      command: :download_file_list,
    }
    @dfl_sha256 = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/uf.xml"),
      command: :upload_file,
    }
    @uf = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/df_vkeur.xml"),
      command: :download_file,
    }
    @df_vkeur = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/df_vkeur_sha256.xml"),
      command: :download_file,
    }
    @df_vkeur_sha256 = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/gui.xml"),
      command: :get_user_info,
    }
    @gui = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/gui_sha256.xml"),
      command: :get_user_info,
    }
    @gui_sha256 = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/gc.xml"),
      command: :get_certificate,
    }
    @gc = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/rc.xml"),
      command: :renew_certificate,
    }
    @rc = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/not_ok_response_code.xml"),
      command: :download_file_list,
    }
    @not_ok_response_code_response = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/download_file_list_no_content.xml"),
      command: :download_file_list,
    }
    @response_with_code_24 = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/invalid/timestamp_altered.xml"),
      command: :download_file_list,
    }
    @timestamp_altered = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/invalid/body_altered.xml"),
      command: :upload_file,
    }
    @body_altered = Sepa::NordeaResponse.new options
  end

  test 'valid responses are valid' do
    assert @dfl.valid?, @dfl.errors.messages
    assert @dfl_sha256.valid?, @dfl_sha256.errors.messages
    # TODO: Can't get upload file to return a valid response in test environment. Maybe fix later.
    # assert @uf.valid?, @uf.errors.messages
    assert @df_vkeur.valid?, @df_vkeur.errors.messages
    assert @df_vkeur_sha256.valid?, @df_vkeur_sha256.errors.messages
    assert @gui.valid?, @gui.errors.messages
    assert @gui_sha256.valid?, @gui_sha256.errors.messages
    # TODO: Can't get get certificate to return a valid response in test environment. Maybe fix later.
    # assert @gc.valid?, @gc.errors.messages
    assert @rc.valid?, @rc.errors.messages
  end

  test 'fails with improper params' do
    a = Sepa::NordeaResponse.new(response: "Jees", command: 'not')
    refute a.valid?
  end

  test 'complains if application response is not valid against schema' do
    a = Sepa::NordeaResponse.new(response: "<ar>text</ar>", command: 'notvalid')
    refute a.valid?
  end

  test 'hashes match with correct responses' do
    assert @df_vkeur.hashes_match?
    assert @df_vkeur_sha256.hashes_match?
    assert @dfl.hashes_match?
    assert @dfl_sha256.hashes_match?
    assert @response_with_code_24
    assert @gc.hashes_match?
    assert @rc.hashes_match?
    assert @gui.hashes_match?
    assert @gui_sha256.hashes_match?
    assert @not_ok_response_code_response.hashes_match?
    assert @uf.hashes_match?
  end

  test 'hashes dont match with incorrect responses' do
    refute @timestamp_altered.hashes_match?
    refute @body_altered.hashes_match?
  end

  test 'response is not valid if hashes dont match' do
    refute @timestamp_altered.valid?
    refute @body_altered.valid?
  end

  test 'certificate verifying against root certificate works' do
    assert @dfl.certificate_is_trusted?
  end

  # TODO: Implement test
  test 'response should not be valid when wrong certificate is embedded in soap' do
  end

  test 'signature verifies with correct responses' do
    assert @df_vkeur.signature_is_valid?
    assert @df_vkeur_sha256.signature_is_valid?
    assert @dfl.signature_is_valid?
    assert @dfl_sha256.signature_is_valid?
    assert @response_with_code_24.signature_is_valid?
    assert @gc.signature_is_valid?
    assert @rc.signature_is_valid?
    assert @gui.signature_is_valid?
    assert @gui_sha256.signature_is_valid?
    assert @not_ok_response_code_response.signature_is_valid?
    assert @uf.signature_is_valid?
  end

  test 'signature should not verify if its integrity has been compromised' do
    refute @timestamp_altered.signature_is_valid?
    refute @body_altered.signature_is_valid?
  end

  test 'to_s works' do
    assert_equal File.read("#{NORDEA_TEST_RESPONSE_PATH}/dfl.xml"), @dfl.to_s
  end

  test 'content can be extracted' do
    refute_nil @df_vkeur.content
    refute_nil @df_vkeur_sha256.content
  end

  test 'content can be extracted from download file list response' do
    refute_nil @dfl.content
    refute_nil @dfl_sha256.content
  end

  test 'file references can be extracted from download file list response' do
    assert_equal 1, @dfl.file_references.length
    assert_equal 1, @dfl_sha256.file_references.length
  end

  test 'upload file list command returns a response' do
    refute_nil @uf.content
  end

  test 'content can be extracted from get user info response' do
    skip "Test environment doesn't return content"

    refute_nil @gui.content
    refute_nil @gui_sha256.content
  end

  test 'certificate can be extracted from get certificate response' do
    assert_nothing_raised { x509_certificate @gc.own_signing_certificate }
  end

  test 'certificate can be extracted from renew certificate response' do
    assert_nothing_raised { x509_certificate @rc.own_signing_certificate }
  end

  test 'response with a response code other than 00 or 24 is considered invalid' do
    refute @not_ok_response_code_response.valid?
    refute_empty @not_ok_response_code_response.errors.messages
  end

  test 'response with a response code of 24 is considered valid' do
    skip "Test environment doesn't return this type of response any more"

    assert @response_with_code_24.valid?
    assert_empty @response_with_code_24.errors.messages
  end
end
