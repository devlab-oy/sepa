require "test_helper"

class SamlinkResponseTest < ActiveSupport::TestCase
  setup do
    @gc_error_30 = Sepa::SamlinkResponse.new(
      response: File.read("#{SAMLINK_TEST_RESPONSE_PATH}/gc_error_30.xml"),
      command: :get_certificate,
    )

    @rc = Sepa::SamlinkResponse.new(
      response: File.read("#{SAMLINK_TEST_RESPONSE_PATH}/rc.xml"),
      command: :renew_certificate,
    )

    @dfl = Sepa::SamlinkResponse.new(
      response: File.read("#{SAMLINK_TEST_RESPONSE_PATH}/dfl.xml"),
      command: :download_file_list,
    )
  end

  test '#response_code' do
    assert_equal "30", @gc_error_30.response_code
    assert_equal "00", @rc.response_code
    assert_equal "00", @dfl.response_code
  end

  test '#response_text' do
    assert_equal "Asiakkaan palvelusopimuksen tarkistuksessa virhe:A00", @gc_error_30.response_text
    assert_equal "OK", @rc.response_text
    assert_equal "OK", @dfl.response_text
  end

  test '#hashes_match' do
    assert @gc_error_30.hashes_match?
    assert @rc.hashes_match?
    assert @dfl.hashes_match?
  end

  test '#signature_is_valid?' do
    assert @gc_error_30.signature_is_valid?
    assert @rc.signature_is_valid?
    assert @dfl.signature_is_valid?
  end

  test '#certificate' do
    assert_equal OpenSSL::X509::Certificate, @gc_error_30.certificate.class
    assert_equal OpenSSL::X509::Certificate, @rc.certificate.class
    assert_equal OpenSSL::X509::Certificate, @dfl.certificate.class
  end

  test '#application_response' do
    refute_empty @gc_error_30.application_response
    refute_empty @rc.application_response
    refute_empty @dfl.application_response
  end

  test '#own_signing_certificate' do
    assert_nil @gc_error_30.own_signing_certificate
    assert_nothing_raised { x509_certificate @rc.own_signing_certificate }
    assert_nil @dfl.own_signing_certificate
  end

  test '#certificate_is_trusted?' do
    assert @rc.certificate_is_trusted?
    assert @dfl.certificate_is_trusted?
  end
end
