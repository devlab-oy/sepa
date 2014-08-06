require 'test_helper'

class NordeaResponseTest < ActiveSupport::TestCase
  include Sepa::Utilities

  def setup
    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/dfl.xml"),
      command: :download_file_list
    }
    @dfl = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/uf.xml"),
      command: :upload_file
    }
    @uf = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/df_tito.xml"),
      command: :download_file
    }
    @df_tito = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/df_ktl.xml"),
      command: :download_file
    }
    @df_ktl = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/gui.xml"),
      command: :get_user_info
    }
    @gui = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/gc.xml"),
      command: :get_certificate
    }
    @gc = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/not_ok_response_code.xml"),
      command: :download_file_list
    }
    @not_ok_response_code_response = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/download_file_list_no_content.xml"),
      command: :download_file_list
    }
    @response_with_code_24 = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/invalid/timestamp_altered.xml"),
      command: :download_file_list
    }
    @timestamp_altered = Sepa::NordeaResponse.new options

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/invalid/body_altered.xml"),
      command: :upload_file
    }
    @body_altered = Sepa::NordeaResponse.new options
  end

  def test_should_be_valid
    assert @dfl.valid?, @dfl.errors.messages
    assert @uf.valid?, @uf.errors.messages
    assert @df_tito.valid?, @df_tito.errors.messages
    assert @df_ktl.valid?, @df_ktl.errors.messages
    assert @gui.valid?, @gui.errors.messages
    assert @gc.valid?, @gc.errors.messages
  end

  def test_should_fail_with_improper_params
    a = Sepa::Response.new({ response: "Jees", command: 'not'})
    refute a.valid?
  end

  def test_should_complain_if_ar_not_valid_against_schema
    a = Sepa::Response.new({ response: "<ar>text</ar>", command: 'notvalid' })
    refute a.valid?
  end

  test 'hashes should match with correct responses' do
    assert @df_ktl.hashes_match?
    assert @df_tito.hashes_match?
    assert @dfl.hashes_match?
    assert @response_with_code_24
    assert @gc.hashes_match?
    assert @gui.hashes_match?
    assert @not_ok_response_code_response.hashes_match?
    assert @uf.hashes_match?
  end

  test 'response should be valid if hashes match and otherwise valid' do
    assert @df_ktl.valid?
    assert @df_tito.valid?
    assert @dfl.valid?
    assert @response_with_code_24
    assert @gc.valid?
    assert @gui.valid?
    assert @uf.valid?
  end

  test 'hashes should not match with incorrect responses' do
    refute @timestamp_altered.hashes_match?
    refute @body_altered.hashes_match?
  end

  test 'response should not be valid if hashes dont match' do
    refute @timestamp_altered.valid?
    refute @body_altered.valid?
  end

  test 'certificate verifying against root certificate works' do
    assert @dfl.certificate_is_trusted?
  end

  test 'response should not be valid when verified against wrong root certificate' do

  end

  test 'signature should verify with correct responses' do
    assert @df_ktl.signature_is_valid?
    assert @df_tito.signature_is_valid?
    assert @dfl.signature_is_valid?
    assert @response_with_code_24.signature_is_valid?
    assert @gc.signature_is_valid?
    assert @gui.signature_is_valid?
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

  ##
  # Tests for download file command

  # tito: Electronic account statement
  def test_content_can_be_extracted_when_file_type_is_tito
    refute_nil @df_tito.content
  end

  # ktl: Incoming reference payments
  def test_content_can_be_extracted_when_file_type_is_ktl
    refute_nil @df_ktl.content
  end

  ##
  # Tests for download file list command

  test 'content can be extracted from download file list response' do
    refute_nil @dfl.content
  end

  test 'file references can be extracted from download file list response' do
    assert_equal 14, @dfl.file_references.length
  end

  ##
  # Tests for upload file list command

  test 'upload file list command returns a response' do
    refute_nil @uf.content
  end

  ##
  # Tests for get user info command

  test 'content can be extracted from get user info response' do
    refute_nil @gui.content
  end

  ##
  # Tests for get certificate command

  test 'certificate can be extracted from get certificate response' do
    assert_nothing_raised do
      x509_certificate @gc.own_signing_certificate
    end
  end

  test 'response with a response code other than 00 or 24 is considered invalid' do
    refute @not_ok_response_code_response.valid?
    refute_empty @not_ok_response_code_response.errors.messages
  end

  test 'response with a response code of 24 is considered valid' do
    assert @response_with_code_24.valid?
    assert_empty @response_with_code_24.errors.messages
  end

end
