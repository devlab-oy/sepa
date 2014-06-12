require 'test_helper'

class NordeaResponseTest < ActiveSupport::TestCase
  include Sepa::Utilities

  def setup
    keys_path = File.expand_path('../keys', __FILE__)
    @root_cert = OpenSSL::X509::Certificate.new File.read("#{keys_path}/root_cert.cer")
    @not_root_cert = OpenSSL::X509::Certificate.new File.read("#{keys_path}/nordea.crt")

    dfl = Nokogiri::XML(File.read("#{NORDEA_TEST_RESPONSE_PATH}/dfl.xml"))
    @dfl = Sepa::Response.new(dfl, command: :download_file_list)

    uf = Nokogiri::XML(File.read("#{NORDEA_TEST_RESPONSE_PATH}/uf.xml"))
    @uf = Sepa::Response.new(uf, command: :upload_file)

    df_tito = Nokogiri::XML(File.read("#{NORDEA_TEST_RESPONSE_PATH}/df_tito.xml"))
    @df_tito = Sepa::Response.new(df_tito, command: :download_file)

    df_ktl = Nokogiri::XML(File.read("#{NORDEA_TEST_RESPONSE_PATH}/df_ktl.xml"))
    @df_ktl = Sepa::Response.new(df_ktl, command: :download_file)

    gui = Nokogiri::XML(File.read("#{NORDEA_TEST_RESPONSE_PATH}/gui.xml"))
    @gui = Sepa::Response.new(gui, command: :get_user_info)

    gc = Nokogiri::XML(File.read("#{NORDEA_TEST_RESPONSE_PATH}/gc.xml"))
    @gc = Sepa::NordeaResponse.new(gc, command: :get_certificate)
  end

  def test_should_be_valid
    assert @dfl.valid?
    assert @uf.valid?
    assert @df_tito.valid?
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
    assert @df_tito.hashes_match?
  end

  def test_cert_check_should_work
    assert @dfl.cert_is_trusted(@root_cert)
    assert_raises(SecurityError) do
     @dfl.cert_is_trusted(@not_root_cert)
   end
  end

  def test_signature_check_should_work
    assert @dfl.signature_is_valid?
    @dfl.soap.at_css(
        'xmlns|SignatureValue',
        'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
      ).content = "kissa"
    refute @dfl.signature_is_valid?
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

  ##
  # Tests for get user info command

  test 'content can be extracted from get user info response' do
    refute_nil @gui.content
  end

  ##
  # Tests for get certificate command

  test 'certificate can be extracted from get certificate response' do
    assert_respond_to @gc.content, :sign
  end
end
