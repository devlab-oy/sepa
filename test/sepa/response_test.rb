require File.expand_path('../../test_helper.rb', __FILE__)

class ResponseTest < MiniTest::Test
  def setup
    keys_path = File.expand_path('../nordea_test_keys', __FILE__)

    @root_cert = OpenSSL::X509::Certificate.new File.read(
      "#{keys_path}/root_cert.cer"
    )

    @not_root_cert = OpenSSL::X509::Certificate.new File.read(
      "#{keys_path}/nordea.crt"
    )

    responses_path = File.expand_path('../test_files/test_responses', __FILE__)

    # Response that was requested with :download_file_list command
    @dfl = Nokogiri::XML(File.read("#{responses_path}/dfl.xml"))

    # Response that was requested with :upload_file command
    @uf = Nokogiri::XML(File.read("#{responses_path}/uf.xml"))

    # Response that was requested with :download_file command
    @df = Nokogiri::XML(File.read("#{responses_path}/df.xml"))

    # Response that was requested with :get_user_info command
    @gui = Nokogiri::XML(File.read("#{responses_path}/gui.xml"))

    # Actual response objects for testing.
    @dfl_response = Sepa::Response.new(@dfl)
    @uf_response = Sepa::Response.new(@uf)
    @df_response = Sepa::Response.new(@df)
    @gui_response = Sepa::Response.new(@gui)
  end

  def test_should_initialize_with_proper_response
    assert Sepa::Response.new(@dfl)
  end

  def test_should_complain_if_initialized_with_something_not_nokogiri_xml
    assert_raises(ArgumentError) { Sepa::Response.new("Sammakko") }
  end

  def test_should_complain_if_response_not_valid_against_schema
    assert_raises(ArgumentError) do
      Sepa::Response.new(Nokogiri::XML("<tomaatti>moikka</tomaatti>"))
    end
  end

  def test_proper_dfl_hash_check_should_verify
    assert Sepa::Response.new(@dfl).hashes_match?
  end

  def test_proper_uf_hash_check_should_verify
    assert Sepa::Response.new(@uf).hashes_match?
  end

  def test_proper_df_hash_check_should_verify
    assert Sepa::Response.new(@df).hashes_match?
  end

  def test_proper_gui_hash_check_should_verify
    assert Sepa::Response.new(@gui).hashes_match?
  end

  def test_corrupted_hash_in_dfl_should_fail_hash_check
    hash_node = @dfl.css(
      'xmlns|DigestValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )[0]

    hash_node.content = Base64.encode64('alsdflsdhf'*6)

    refute Sepa::Response.new(@dfl).hashes_match?
  end

  def test_corrupted_hash_in_uf_should_fail_hash_check
    hash_node = @uf.css(
      'xmlns|DigestValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )[1]

    wrong_value = Base64.encode64(OpenSSL::Digest::SHA1.new.digest('hemuli'))

    hash_node.content = wrong_value

    refute Sepa::Response.new(@uf).hashes_match?
  end

  def test_corrupted_hash_in_df_should_fail_hash_check
    hash_node = @df.css(
      'xmlns|DigestValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )[0]
    wrong_value = Base64.encode64(
      OpenSSL::Digest::SHA1.new.digest('whatifitoldyouimnotavalidvalueforhash' \
                                       'ing')
    )

    hash_node.content = wrong_value

    refute Sepa::Response.new(@df).hashes_match?
  end

  def test_corrupted_hash_in_gui_should_fail_hash_check
    hash_node = @gui.css(
      'xmlns|DigestValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )[1]

    hash_node.content = hash_node.content[6..-1]

    refute Sepa::Response.new(@gui).hashes_match?
  end

  def test_proper_dfl_signature_should_verify
    assert Sepa::Response.new(@dfl).signature_is_valid?
  end

  def test_proper_uf_signature_should_verify
    assert Sepa::Response.new(@uf).signature_is_valid?
  end

  def test_proper_df_signature_should_verify
    assert Sepa::Response.new(@df).signature_is_valid?
  end

  def test_proper_gui_signature_should_verify
    assert Sepa::Response.new(@gui).signature_is_valid?
  end

  def test_corrupted_signature_in_dfl_should_fail_signature_verification
    signature_node = @dfl.at_css(
      'xmlns|SignatureValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )

    signature_node.content = signature_node.content[1..-1]

    refute Sepa::Response.new(@dfl).signature_is_valid?
  end

  def test_corrupted_signature_in_uf_should_fail_signature_verification
    signature_node = @uf.at_css(
      'xmlns|SignatureValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )

    signature_node.content = signature_node.content[6..-4]

    refute Sepa::Response.new(@uf).signature_is_valid?
  end

  def test_corrupted_signature_in_df_should_fail_signature_verification
    signature_node = @df.at_css(
      'xmlns|SignatureValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )

    signature_node.content = signature_node.content[0..-2]

    refute Sepa::Response.new(@df).signature_is_valid?
  end

  def test_corrupted_signature_in_gui_should_fail_signature_verification
    signature_node = @gui.at_css(
      'xmlns|SignatureValue',
      'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    )

    signature_node.content = 'i' + signature_node.content

    refute Sepa::Response.new(@gui).signature_is_valid?
  end

  def test_should_raise_error_if_certificate_corrupted_in_dfl
    cert_node = @dfl.at_css(
      'wsse|BinarySecurityToken',
      'wsse' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-ws' \
      'security-secext-1.0.xsd'
    )

    cert_node.content = cert_node.content + 'a'

    assert_raises(OpenSSL::X509::CertificateError) do
      Sepa::Response.new(@dfl).signature_is_valid?
    end
  end

  def test_should_raise_error_if_certificate_corrupted_in_uf
    cert_node = @uf.at_css(
      'wsse|BinarySecurityToken',
      'wsse' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-ws' \
      'security-secext-1.0.xsd'
    )

    cert_node.content = cert_node.content[1..-1]

    assert_raises(OpenSSL::X509::CertificateError) do
      Sepa::Response.new(@uf).signature_is_valid?
    end
  end

  def test_should_raise_error_if_certificate_corrupted_in_df
    cert_node = @df.at_css(
      'wsse|BinarySecurityToken',
      'wsse' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-ws' \
      'security-secext-1.0.xsd'
    )

    cert_node.content = cert_node.content[0..-5]

    assert_raises(OpenSSL::X509::CertificateError) do
      Sepa::Response.new(@df).signature_is_valid?
    end
  end

  def test_should_raise_error_if_certificate_corrupted_in_gui
    cert_node = @gui.at_css(
      'wsse|BinarySecurityToken',
      'wsse' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-ws' \
      'security-secext-1.0.xsd'
    )

    cert_node.content = cert_node.content[9..-1]

    assert_raises(OpenSSL::X509::CertificateError) do
      Sepa::Response.new(@gui).signature_is_valid?
    end
  end

  def test_should_return_certificate_with_certificate_method
    assert @dfl_response.certificate.respond_to?(:public_key)
    assert @uf_response.certificate.respond_to?(:public_key)
    assert @df_response.certificate.respond_to?(:public_key)
    assert @gui_response.certificate.respond_to?(:public_key)
  end

  def test_cert_should_be_trusted_with_correct_root_cert
    assert @dfl_response.cert_is_trusted?(@root_cert)
    assert @uf_response.cert_is_trusted?(@root_cert)
    assert @df_response.cert_is_trusted?(@root_cert)
    assert @gui_response.cert_is_trusted?(@root_cert)
  end

  def test_dfl_should_fail_if_wrong_root_cert
    assert_raises(SecurityError) do
      @dfl_response.cert_is_trusted?(@not_root_cert)
    end
  end

  def test_uf_should_fail_if_wrong_root_cert
    assert_raises(SecurityError) do
      @uf_response.cert_is_trusted?(@not_root_cert)
    end
  end

  def test_df_should_fail_if_wrong_root_cert
    assert_raises(SecurityError) do
      @df_response.cert_is_trusted?(@not_root_cert)
    end
  end

  def test_gui_should_fail_if_wrong_root_cert
    assert_raises(SecurityError) do
      @gui_response.cert_is_trusted?(@not_root_cert)
    end
  end
end
