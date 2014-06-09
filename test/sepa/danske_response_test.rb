require 'test_helper'

class DanskeResponseTest < ActiveSupport::TestCase
  KEYS_PATH = File.expand_path('../danske_test_keys', __FILE__)
  ROOT_CERT = OpenSSL::X509::Certificate.new File.read("#{KEYS_PATH}/bank_root_cert.pem")
  NOT_ROOT_CERT = OpenSSL::X509::Certificate.new File.read("#{KEYS_PATH}/bank_encryption_cert.pem")

  def setup
    dfl = Nokogiri::XML(File.read("#{TEST_RESPONSE_PATH}/dfl.xml"))
    @dfl = Sepa::Response.new(dfl, command: :download_file_list)

    uf = Nokogiri::XML(File.read("#{TEST_RESPONSE_PATH}/uf.xml"))
    @uf = Sepa::Response.new(uf, command: :upload_file)

    df = Nokogiri::XML(File.read("#{TEST_RESPONSE_PATH}/df.xml"))
    @df = Sepa::Response.new(df, command: :download_file)

    gui = Nokogiri::XML(File.read("#{TEST_RESPONSE_PATH}/gui.xml"))
    @gui = Sepa::Response.new(gui, command: :get_user_info)
  end

  def test_should_be_valid
    assert @dfl.valid?
    assert @uf.valid?
    assert @df.valid?
    assert @gui.valid?
  end

  def test_should_fail_with_improper_params
    a = Sepa::Response.new("Jees", command: 'not')
    refute a.valid?
  end

  def test_should_complain_if_ar_not_valid_against_schema
    a = Sepa::Response.new(Nokogiri::XML("<ar>text</ar>"), command: 'notvalid')
    refute a.valid?
  end

  def test_hashes_match_works
    assert @gui.hashes_match?
    assert @dfl.hashes_match?
    assert @uf.hashes_match?
    assert @df.hashes_match?
  end

  def test_cert_check_should_work
    assert @dfl.cert_is_trusted(ROOT_CERT)
    assert_raises(SecurityError) do
      @dfl.cert_is_trusted(NOT_ROOT_CERT)
    end
  end

  def test_signature_check_should_work
    assert @dfl.signature_is_valid?
    @dfl.document.at_css(
        'xmlns|SignatureValue',
        'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
    ).content = "kissa"
    refute @dfl.signature_is_valid?
  end

end
