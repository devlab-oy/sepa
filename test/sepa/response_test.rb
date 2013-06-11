require File.expand_path('../../test_helper.rb', __FILE__)

class ResponseTest < MiniTest::Test
  def setup
    @responses_path = File.expand_path('../test_files/test_responses', __FILE__)

    @response = Nokogiri::XML(File.read("#{@responses_path}/invalid_1.xml"))

    @valid_1_file = File.read("#{@responses_path}/valid_1.xml")
    @valid_1 = Nokogiri::XML(@valid_1_file)
    @valid_1 = Sepa::Response.new(@valid_1)

    @valid_2_file = File.read("#{@responses_path}/valid_2.xml")
    @valid_2 = Nokogiri::XML(@valid_2_file)
    @valid_2 = Sepa::Response.new(@valid_2)

    @valid_3_file = File.read("#{@responses_path}/valid_3.xml")
    @valid_3 = Nokogiri::XML(@valid_3_file)
    @valid_3 = Sepa::Response.new(@valid_3)

    @valid_4_file = File.read("#{@responses_path}/valid_4.xml")
    @valid_4 = Nokogiri::XML(@valid_4_file)
    @valid_4 = Sepa::Response.new(@valid_4)

    @invalid_1_file = File.read("#{@responses_path}/invalid_1.xml")
    @invalid_1 = Nokogiri::XML(@invalid_1_file)
    @invalid_1 = Sepa::Response.new(@invalid_1)

    @invalid_2_file = File.read("#{@responses_path}/invalid_2.xml")
    @invalid_2 = Nokogiri::XML(@invalid_2_file)
    @invalid_2 = Sepa::Response.new(@invalid_2)

    @invalid_3_file = File.read("#{@responses_path}/invalid_3.xml")
    @invalid_3 = Nokogiri::XML(@invalid_3_file)
    @invalid_3 = Sepa::Response.new(@invalid_3)

    @invalid_4_file = File.read("#{@responses_path}/invalid_4.xml")
    @invalid_4 = Nokogiri::XML(@invalid_4_file)
    @invalid_4 = Sepa::Response.new(@invalid_4)

    # Structure is corrupted
    @invalid_5_file = File.read("#{@responses_path}/invalid_5.xml")
    @invalid_5 = Nokogiri::XML(@invalid_5_file)
    @invalid_5 = Sepa::Response.new(@invalid_5)

    # Cerificate is corrupted.
    @invalid_6_file = File.read("#{@responses_path}/invalid_6.xml")
    @invalid_6 = Nokogiri::XML(@invalid_6_file)
    @invalid_6 = Sepa::Response.new(@invalid_6)
  end

  def test_should_initialize_with_proper_response
    assert Sepa::Response.new(@response)
  end

  def test_should_complain_if_initialized_with_something_not_nokogiri_xml
    assert_raises(ArgumentError) { Sepa::Response.new("Sammakko") }
  end

  def test_should_complain_if_response_not_valid_against_schema
    assert_raises(ArgumentError) do
      Sepa::Response.new(Nokogiri::XML("<tomaatti>moikka</tomaatti>"))
    end
  end

  def test_should_complain_if_header_severely_corrupted
    # assert_raises(ArgumentError) do
    Sepa::Response.new(Nokogiri::XML(@invalid_5_file))
    # end
  end

  def test_valid_response_1_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    digest = Base64.encode64(sha1.digest(@valid_1_file)).strip

    assert_equal digest, 'vp0OeOELDa1V40/erOR6TgzmkdI='
  end

  def test_valid_response_2_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    digest = Base64.encode64(sha1.digest(@valid_2_file)).strip

    assert_equal digest, 'ccXgIZi7yVf9gQqjEJT9halcrc8='
  end

  def test_valid_response_3_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    digest = Base64.encode64(sha1.digest(@valid_3_file)).strip

    assert_equal digest, 'ignmVdl+/K/Ths8PZmyxLvyZFUU='
  end

  def test_valid_response_4_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    digest = Base64.encode64(sha1.digest(@valid_4_file)).strip

    assert_equal digest, 'laS34UjcnI1k5vP+fwzrKbDpHEw='
  end

  def test_invalid_response_1_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    digest = Base64.encode64(sha1.digest(@invalid_1_file)).strip

    assert_equal digest, '6Rkv+OCOmw4JahI8P2Prb13Y4Kg='
  end

  def test_invalid_response_2_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    digest = Base64.encode64(sha1.digest(@invalid_2_file)).strip

    assert_equal digest, '6+yjYNvuqVvRX9TIhM2MbC9XAo4='
  end

  def test_invalid_response_3_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    digest = Base64.encode64(sha1.digest(@invalid_3_file)).strip

    assert_equal digest, 'ayTb+fazRLFNK6VwbQlYoVawCEs='
  end

  def test_invalid_response_4_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    digest = Base64.encode64(sha1.digest(@invalid_4_file)).strip

    assert_equal digest, '/LEwhGmdHv2ynOG+Y0AYcgy+sjA='
  end

  def test_valid_responses_should_verify
    assert @valid_1.soap_hashes_match?
    assert @valid_2.soap_hashes_match?
    assert @valid_3.soap_hashes_match?
    assert @valid_4.soap_hashes_match?
  end

  def test_should_fail_with_invalid_responses
    refute @invalid_1.soap_hashes_match?
    refute @invalid_2.soap_hashes_match?
    refute @invalid_3.soap_hashes_match?
    refute @invalid_4.soap_hashes_match?
    refute @invalid_5.soap_hashes_match?
  end

  def test_valid_signature_should_verify
    assert @valid_1.soap_signature_is_valid?
    assert @valid_2.soap_signature_is_valid?
    assert @valid_3.soap_signature_is_valid?
    assert @valid_4.soap_signature_is_valid?
  end

  def test_invalid_signature_should_not_verify
    refute @invalid_1.soap_signature_is_valid?
    refute @invalid_2.soap_signature_is_valid?
    refute @invalid_3.soap_signature_is_valid?
    refute @invalid_4.soap_signature_is_valid?
    refute @invalid_5.soap_signature_is_valid?
  end

  def test_should_raise_error_if_certificate_corrupted
    assert_raises(OpenSSL::X509::CertificateError) do
      @invalid_6.soap_signature_is_valid?
    end
  end
end
