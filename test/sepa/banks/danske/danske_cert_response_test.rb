require 'test_helper'

class DanskeCertResponseTest < ActiveSupport::TestCase
  setup do
    options = {
      response: File.read("#{DANSKE_TEST_RESPONSE_PATH}get_bank_cert.xml"),
      command: :get_bank_certificate,
    }
    @get_bank_cert_response = Sepa::DanskeResponse.new options

    options = {
      response: File.read("#{DANSKE_TEST_RESPONSE_PATH}create_cert.xml"),
      command: :create_certificate,
    }
    @create_certificate_response = Sepa::DanskeResponse.new options

    options = {
      response: File.read("#{DANSKE_TEST_RESPONSE_PATH}create_cert_corrupted.xml"),
      command: :create_certificate,
    }
    @create_certificate_corrupted_response = Sepa::DanskeResponse.new options

    options = {
      response: File.read("#{DANSKE_TEST_RESPONSE_PATH}get_bank_certificate_not_ok.xml"),
      command: :get_bank_certificate,
    }
    @get_bank_certificate_not_ok_response = Sepa::DanskeResponse.new options
  end

  test 'correct responses should be valid' do
    assert @get_bank_cert_response.valid?, @get_bank_cert_response.errors.messages
    assert @create_certificate_response.valid?, @create_certificate_response.errors.messages
  end

  # Tests for get bank certificate
  test 'should have correct bank signing cert with get_bank_certificate command' do
    bank_signing_cert = @get_bank_cert_response.bank_signing_certificate
    refute_nil bank_signing_cert
    assert_equal bank_signing_cert.to_s, DANSKE_BANK_SIGNING_CERT
  end

  test 'should have corrent bank encryption cert with get bank certificate command' do
    bank_encryption_cert = @get_bank_cert_response.bank_encryption_certificate
    refute_nil bank_encryption_cert
    assert_equal bank_encryption_cert.to_s, DANSKE_BANK_ENCRYPTION_CERT
  end

  test 'should have correct bank root certificate with get bank certificate command' do
    bank_root_cert = @get_bank_cert_response.bank_root_certificate
    refute_nil bank_root_cert
    assert_equal bank_root_cert.to_s, DANSKE_BANK_ROOT_CERT
  end

  # Tests for create certificate
  test 'should have own encryption certificate with create certificate command' do
    own_encryption_cert = @create_certificate_response.own_encryption_certificate
    refute_nil own_encryption_cert
    assert own_encryption_cert.respond_to? :sign
  end

  test 'should have on signing certificate with create certificate command' do
    own_signing_cert = @create_certificate_response.own_signing_certificate
    refute_nil own_signing_cert
    assert own_signing_cert.respond_to? :sign
  end

  test 'should have correct CA certificate with create certificate command' do
    ca_certificate = @create_certificate_response.ca_certificate
    refute_nil ca_certificate
    assert ca_certificate.respond_to? :sign
  end

  test 'hashes should match' do
    assert @get_bank_cert_response.hashes_match?
    assert @create_certificate_response.hashes_match?
  end

  test 'hashes shouldnt match if they are not found' do
    refute @get_bank_certificate_not_ok_response.hashes_match?
  end

  test 'hashes shouldnt match when data is corrupted' do
    assert_output(/These digests failed to verify: {"#response"=>"2vCYl3h7ksRgk7IyV2axgpXxTWM="}/) do
      refute @create_certificate_corrupted_response.hashes_match?(verbose: true)
    end
  end

  test 'signatures in correct responses should verify' do
    assert @get_bank_cert_response.signature_is_valid?
    assert @create_certificate_response.signature_is_valid?
  end

  test 'signature should not verify if not found' do
    refute @get_bank_certificate_not_ok_response.signature_is_valid?
  end

  test 'should not be valid when response code is not 00 in get bank certificate' do
    refute @get_bank_certificate_not_ok_response.valid?
    refute_empty @get_bank_certificate_not_ok_response.errors.messages
  end

  test 'should be valid when response code is 00 in get bank certificate' do
    assert @get_bank_cert_response.valid?, @get_bank_cert_response.errors.messages
    assert_empty @get_bank_cert_response.errors.messages
  end

  test 'certificate used to sign the response can be extracted' do
    certificate = @create_certificate_response.certificate

    assert_nothing_raised do
      x509_certificate certificate
    end
  end
end
