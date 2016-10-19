require 'test_helper'

class NordeaApplicationResponseTest < ActiveSupport::TestCase
  include Sepa::Utilities

  KEYS_PATH = File.expand_path('../keys', __FILE__)

  def setup
    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/dfl.xml"),
      command: :download_file_list,
    }
    @dfl = Sepa::NordeaResponse.new(options).application_response
    @dfl_doc = xml_doc @dfl

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/uf.xml"),
      command: :upload_file,
    }
    @uf = Sepa::NordeaResponse.new(options).application_response
    @uf_doc = xml_doc @dfl

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/df_tito.xml"),
      command: :download_file,
    }
    @df_tito = Sepa::NordeaResponse.new(options).application_response
    @df_tito_doc = xml_doc @df_tito

    options = {
      response: File.read("#{NORDEA_TEST_RESPONSE_PATH}/gui.xml"),
      command: :get_user_info,
    }
    @gui = Sepa::NordeaResponse.new(options).application_response
    @gui_doc = xml_doc @gui

    @dfl_ar = Sepa::ApplicationResponse.new(@dfl, :nordea)
    @uf_ar = Sepa::ApplicationResponse.new(@uf, :nordea)
    @df_ar = Sepa::ApplicationResponse.new(@df_tito, :nordea)
    @gui_ar = Sepa::ApplicationResponse.new(@gui, :nordea)
  end

  def test_templates_valid
    assert @dfl_ar.valid?
    assert @uf_ar.valid?
    assert @df_ar.valid?
    assert @gui_ar.valid?
  end

  def test_should_fail_if_initialized_with_invalid_xml
    as = Sepa::ApplicationResponse.new("Jees", :nordea)
    refute as.valid?
  end

  def test_should_complain_if_ar_not_valid_against_schema
    as = Sepa::ApplicationResponse.new(Nokogiri::XML("<ar>text</ar>"), :nordea)
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
    customer_id_node = @dfl_doc.at_css('c2b|CustomerId')
    customer_id_node.content = customer_id_node.content[0..-2]

    refute Sepa::ApplicationResponse.new(@dfl_doc.to_s, :nordea).hashes_match?
  end

  def test_invalid_uf_hash_check_should_not_verify
    timestamp_node = @uf_doc.at_css('c2b|Timestamp')
    timestamp_node.content = Time.now.iso8601

    refute Sepa::ApplicationResponse.new(@uf_doc.to_s, :nordea).hashes_match?
  end

  def test_invalid_df_hash_check_should_not_verify
    digest_value_node = @df_tito_doc.at_css(
      'xmlns|DigestValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#',
    )

    digest_value_node.content = digest_value_node.content[4..-1]

    refute Sepa::ApplicationResponse.new(@df_tito_doc.to_s, :nordea).hashes_match?
  end

  def test_invalid_gui_hash_check_should_not_verify
    digest_value_node = @gui_doc.at_css(
      'xmlns|DigestValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#',
    )

    digest_value_node.content = '1234' + digest_value_node.content

    refute Sepa::ApplicationResponse.new(@gui_doc.to_s, :nordea).hashes_match?
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
    signature_node = @dfl_doc.at_css(
      'xmlns|SignatureValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#',
    )

    signature_node.content = signature_node.content[4..-1]

    refute Sepa::ApplicationResponse.new(@dfl_doc.to_s, :nordea).signature_is_valid?
  end

  def test_corrupted_signature_in_uf_should_fail_signature_verification
    signature_node = @uf_doc.at_css(
      'xmlns|SignatureValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#',
    )

    signature_node.content = signature_node.content[0..-5]

    refute Sepa::ApplicationResponse.new(@uf_doc.to_s, :nordea).signature_is_valid?
  end

  def test_corrupted_signature_in_df_should_fail_signature_verification
    signature_node = @df_tito_doc.at_css(
      'xmlns|SignatureValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#',
    )

    signature_node.content = 'a' + signature_node.content[1..-1]

    refute Sepa::ApplicationResponse.new(@df_tito_doc.to_s, :nordea).signature_is_valid?
  end

  def test_corrupted_signature_in_gui_should_fail_signature_verification
    signature_node = @gui_doc.at_css(
      'xmlns|SignatureValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#',
    )

    signature_node.content = 'zombi' + signature_node.content[1..-1]

    refute Sepa::ApplicationResponse.new(@gui_doc.to_s, :nordea).signature_is_valid?
  end

  def test_should_raise_error_if_certificate_corrupted_in_dfl
    cert_node = @dfl_doc.at_css(
      'xmlns|X509Certificate',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#',
    )

    cert_node.content = cert_node.content[0..-5]

    assert_raises(OpenSSL::X509::CertificateError) do
      Sepa::ApplicationResponse.new(@dfl_doc.to_s, :nordea).certificate
    end
  end

  def test_should_raise_error_if_certificate_corrupted_in_uf
    cert_node = @uf_doc.at_css(
      'xmlns|X509Certificate',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#',
    )

    cert_node.content = cert_node.content[4..-1]

    assert_raises(OpenSSL::X509::CertificateError) do
      Sepa::ApplicationResponse.new(@uf_doc.to_s, :nordea).certificate
    end
  end

  def test_should_raise_error_if_certificate_corrupted_in_df
    cert_node = @df_tito_doc.at_css(
      'xmlns|X509Certificate',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#',
    )

    cert_node.content = "n5iw#{cert_node.content}"

    assert_raises(OpenSSL::X509::CertificateError) do
      Sepa::ApplicationResponse.new(@df_tito_doc.to_s, :nordea).certificate
    end
  end

  def test_should_raise_error_if_certificate_corrupted_in_gui
    cert_node = @gui_doc.at_css(
      'xmlns|X509Certificate',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#',
    )

    cert_node.content = encode 'voivoi'

    assert_raises(OpenSSL::X509::CertificateError) do
      Sepa::ApplicationResponse.new(@gui_doc.to_s, :nordea).certificate
    end
  end

  test 'certificate is trusted with correct root certificate' do
    assert @dfl_ar.certificate_is_trusted?
    assert @uf_ar.certificate_is_trusted?
    assert @df_ar.certificate_is_trusted?
    assert @gui_ar.certificate_is_trusted?
  end

  # TODO: Implement test
  test 'certificate is not trusted with incorrect root certificate' do
  end

  test 'to_s works' do
    assert_equal @uf, @uf_ar.to_s
  end
end
