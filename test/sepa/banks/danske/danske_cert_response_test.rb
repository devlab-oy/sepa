require 'test_helper'

class DanskeCertResponseTest < ActiveSupport::TestCase

  options = {
    response: (File.open "#{DANSKE_TEST_RESPONSE_PATH}get_bank_cert.xml"),
    command: :get_bank_certificate
  }
  get_bank_cert_response = Sepa::DanskeResponse.new options

  options = {
    response: (File.open "#{DANSKE_TEST_RESPONSE_PATH}create_cert.xml"),
    command: :create_certificate
  }
  create_certificate_response = Sepa::DanskeResponse.new options

  # Tests for get bank certificate
  test 'should have correct bank signing cert with get_bank_certificate command' do
    bank_signing_cert = get_bank_cert_response.bank_signing_cert
    refute_nil bank_signing_cert
    assert_equal bank_signing_cert.to_s, DANSKE_BANK_SIGNING_CERT
  end

  test 'should have corrent bank encryption cert with get bank certificate command' do
    bank_encryption_cert = get_bank_cert_response.bank_encryption_cert
    refute_nil bank_encryption_cert
    assert_equal bank_encryption_cert.to_s, DANSKE_BANK_ENCRYPTION_CERT
  end

  test 'should have correct bank root cert with get bank certificate command' do
    bank_root_cert = get_bank_cert_response.bank_root_cert
    refute_nil bank_root_cert
    assert_equal bank_root_cert.to_s, DANSKE_BANK_ROOT_CERT
  end

  # Tests for create certificate
  test 'should have own encryption certificate with create certificate command' do
    own_encryption_cert = create_certificate_response.own_encryption_cert
    refute_nil own_encryption_cert
    assert own_encryption_cert.respond_to? :sign
  end

  test 'should have on signing certificate with create certificate command' do
    own_signing_cert = create_certificate_response.own_signing_cert
    refute_nil own_signing_cert
    assert own_signing_cert.respond_to? :sign
  end

  test 'should have correct CA certificate with create certificate command' do
    ca_certificate = create_certificate_response.ca_certificate
    refute_nil ca_certificate
    assert ca_certificate.respond_to? :sign
  end

  test 'hashes should match' do
    assert create_certificate_response.hashes_match?
  end

end
