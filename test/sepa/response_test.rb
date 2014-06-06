require 'test_helper'

class ResponseTest < ActiveSupport::TestCase

  def setup
    keys_path = File.expand_path('../nordea_test_keys', __FILE__)
    @root_cert = OpenSSL::X509::Certificate.new File.read("#{keys_path}/root_cert.cer")
    @not_root_cert = OpenSSL::X509::Certificate.new File.read("#{keys_path}/nordea.crt")

    dfl = Nokogiri::XML(File.read("#{TEST_RESPONSE_PATH}/dfl.xml"))
    @dfl = Sepa::Response.new(dfl)

    uf = Nokogiri::XML(File.read("#{TEST_RESPONSE_PATH}/uf.xml"))
    @uf = Sepa::Response.new(uf)

    df = Nokogiri::XML(File.read("#{TEST_RESPONSE_PATH}/df.xml"))
    @df = Sepa::Response.new(df)

    gui = Nokogiri::XML(File.read("#{TEST_RESPONSE_PATH}/gui.xml"))
    @gui = Sepa::Response.new(gui)
  end

  def test_should_be_valid
    assert @dfl.valid?
    assert @uf.valid?
    assert @df.valid?
    assert @gui.valid?
  end

  def test_should_fail_with_improper_params
    a = Sepa::Response.new("Jees")
    refute a.valid?
  end

  def test_should_complain_if_ar_not_valid_against_schema
    a = Sepa::Response.new(Nokogiri::XML("<ar>text</ar>"))
    refute a.valid?
  end

  def test_hashes_match_works
    assert @gui.hashes_match?
    assert @dfl.hashes_match?
    assert @uf.hashes_match?
    assert @df.hashes_match?
  end

  def test_cert_check_should_work
    assert @dfl.cert_is_trusted(@root_cert)
    assert_raises(SecurityError) do
     @dfl.cert_is_trusted(@not_root_cert)
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
