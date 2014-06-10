require 'test_helper'

class NordeaApplicationResponseTest < ActiveSupport::TestCase

  def setup
    keys_path = File.expand_path('../keys', __FILE__)
    @root_cert = OpenSSL::X509::Certificate.new File.read("#{keys_path}/root_cert.cer")
    @not_root_cert = OpenSSL::X509::Certificate.new File.read("#{keys_path}/nordea.crt")

    @dfl = Nokogiri::XML(File.read("#{NORDEA_TEST_RESPONSE_PATH}/dfl.xml"))
    @dfl = Sepa::Response.new(@dfl, command: :download_file_list).application_response

    @uf = Nokogiri::XML(File.read("#{NORDEA_TEST_RESPONSE_PATH}/uf.xml"))
    @uf = Sepa::Response.new(@uf, command: :upload_file).application_response

    @df_tito = Nokogiri::XML(File.read("#{NORDEA_TEST_RESPONSE_PATH}/df_tito.xml"))
    @df_tito = Sepa::Response.new(@df_tito, command: :download_file).application_response

    @gui = Nokogiri::XML(File.read("#{NORDEA_TEST_RESPONSE_PATH}/gui.xml"))
    @gui = Sepa::Response.new(@gui, command: :get_user_info).application_response

    @dfl_ar = Sepa::ApplicationResponse.new(@dfl)
    @uf_ar = Sepa::ApplicationResponse.new(@uf)
    @df_ar = Sepa::ApplicationResponse.new(@df_tito)
    @gui_ar = Sepa::ApplicationResponse.new(@gui)
  end

  def test_templates_valid
    assert @dfl_ar.valid?
    assert @uf_ar.valid?
    assert @df_ar.valid?
    assert @gui_ar.valid?
  end

  def test_should_fail_if_initialized_with_not_nokogiri_xml
    as = Sepa::ApplicationResponse.new("Jees")
    refute as.valid?
  end

  def test_should_complain_if_ar_not_valid_against_schema
    as = Sepa::ApplicationResponse.new(Nokogiri::XML("<ar>text</ar>"))
    refute as.valid?
  end

  def test_proper_dfl_hash_check_should_verify
    assert @dfl_ar.hashes_match?
  end

  def test_proper_uf_hash_check_should_verify
    assert @uf_ar.hashes_match?
  end

  def test_proper_df_hash_check_should_verify
    assert @df_ar.hashes_match?
  end

  def test_proper_gui_hash_check_should_verify
    assert @gui_ar.hashes_match?
  end

  def test_invalid_dfl_hash_check_should_not_verify
    customer_id_node = @dfl.at_css('c2b|CustomerId')
    customer_id_node.content = customer_id_node.content[0..-2]

    refute Sepa::ApplicationResponse.new(@dfl).hashes_match?
  end

  def test_invalid_uf_hash_check_should_not_verify
    timestamp_node = @uf.at_css('c2b|Timestamp')
    timestamp_node.content = Time.now.iso8601

    refute Sepa::ApplicationResponse.new(@uf).hashes_match?
  end

  def test_invalid_df_hash_check_should_not_verify
    digest_value_node = @df_tito.at_css(
      'xmlns|DigestValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )

    digest_value_node.content = digest_value_node.content[4..-1]

    refute Sepa::ApplicationResponse.new(@df_tito).hashes_match?
  end

  def test_invalid_gui_hash_check_should_not_verify
    digest_value_node = @gui.at_css(
      'xmlns|DigestValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )

    digest_value_node.content = '1234' + digest_value_node.content

    refute Sepa::ApplicationResponse.new(@gui).hashes_match?
  end

  def test_proper_dfl_signature_should_verify
    assert @dfl_ar.signature_is_valid?
  end

  def test_proper_uf_signature_should_verify
    assert @uf_ar.signature_is_valid?
  end

  def test_proper_df_signature_should_verify
    assert @df_ar.signature_is_valid?
  end

  def test_proper_gui_signature_should_verify
    assert @gui_ar.signature_is_valid?
  end

  def test_corrupted_signature_in_dfl_should_fail_signature_verification
    signature_node = @dfl.at_css(
      'xmlns|SignatureValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )

    signature_node.content = signature_node.content[4..-1]

    refute Sepa::ApplicationResponse.new(@dfl).signature_is_valid?
  end

  def test_corrupted_signature_in_uf_should_fail_signature_verification
    signature_node = @uf.at_css(
      'xmlns|SignatureValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )

    signature_node.content = signature_node.content[0..-5]

    refute Sepa::ApplicationResponse.new(@uf).signature_is_valid?
  end

  def test_corrupted_signature_in_df_should_fail_signature_verification
    signature_node = @df_tito.at_css(
      'xmlns|SignatureValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )

    signature_node.content = 'a' + signature_node.content[1..-1]

    refute Sepa::ApplicationResponse.new(@df_tito).signature_is_valid?
  end

  def test_corrupted_signature_in_gui_should_fail_signature_verification
    signature_node = @gui.at_css(
      'xmlns|SignatureValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )

    signature_node.content = 'zombi' + signature_node.content[1..-1]

    refute Sepa::ApplicationResponse.new(@gui).signature_is_valid?
  end

  def test_should_raise_error_if_certificate_corrupted_in_dfl
    cert_node = @dfl.at_css(
      'xmlns|X509Certificate',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )

    cert_node.content = cert_node.content[0..-5]

    assert_raises(OpenSSL::X509::CertificateError) do
      Sepa::ApplicationResponse.new(@dfl).certificate
    end
  end

  def test_should_raise_error_if_certificate_corrupted_in_uf
    cert_node = @uf.at_css(
      'xmlns|X509Certificate',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )

    cert_node.content = cert_node.content[4..-1]

    assert_raises(OpenSSL::X509::CertificateError) do
      Sepa::ApplicationResponse.new(@uf).certificate
    end
  end

  def test_should_raise_error_if_certificate_corrupted_in_df
    cert_node = @df_tito.at_css(
      'xmlns|X509Certificate',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )

    cert_node.content = "n5iw#{cert_node.content}"

    assert_raises(OpenSSL::X509::CertificateError) do
      Sepa::ApplicationResponse.new(@df_tito).certificate
    end
  end

  def test_should_raise_error_if_certificate_corrupted_in_gui
    cert_node = @gui.at_css(
      'xmlns|X509Certificate',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )

    cert_node.content = Base64.encode64('voivoi')

    assert_raises(OpenSSL::X509::CertificateError) do
      Sepa::ApplicationResponse.new(@gui).certificate
    end
  end

  def test_cert_should_be_trusted_with_correct_root_cert
    assert @dfl_ar.cert_is_trusted(@root_cert)
    assert @uf_ar.cert_is_trusted(@root_cert)
    assert @df_ar.cert_is_trusted(@root_cert)
    assert @gui_ar.cert_is_trusted(@root_cert)
  end

  def test_dfl_should_fail_if_wrong_root_cert
    assert_raises(SecurityError) { @dfl_ar.cert_is_trusted(@not_root_cert) }
  end

  def test_uf_should_fail_if_wrong_root_cert
    assert_raises(SecurityError) { @uf_ar.cert_is_trusted(@not_root_cert) }
  end

  def test_df_should_fail_if_wrong_root_cert
    assert_raises(SecurityError) { @df_ar.cert_is_trusted(@not_root_cert) }
  end

  def test_gui_should_fail_if_wrong_root_cert
    assert_raises(SecurityError) { @gui_ar.cert_is_trusted(@not_root_cert) }
  end

end
