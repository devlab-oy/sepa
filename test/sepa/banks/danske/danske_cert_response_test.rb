require 'test_helper'

class DanskeCertResponseTest < ActiveSupport::TestCase


  get_bank_cert_soap = Nokogiri::XML(File.open "#{DANSKE_TEST_RESPONSE_PATH}get_bank_cert.xml")

  get_bank_cert_response = Sepa::DanskeResponse.new(get_bank_cert_soap, command: :get_bank_certificate)

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
end
