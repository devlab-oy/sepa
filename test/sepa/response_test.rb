require File.expand_path('../../test_helper.rb', __FILE__)

class ResponseTest < MiniTest::Test
  def setup
    @responses_path = File.expand_path('../test_files/test_responses', __FILE__)

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
  end

  def test_should_initialize_with_proper_params
    assert Sepa::Response.new(@valid_1)
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

    assert_equal digest, 'OVqP4mRPds+jFpFnl/SgDW4z+as='
  end

  def test_invalid_response_2_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    digest = Base64.encode64(sha1.digest(@invalid_2_file)).strip

    assert_equal digest, 'rn/RyClIIVkKGk3ZhbMKD9lRrNM='
  end

  def test_invalid_response_3_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    digest = Base64.encode64(sha1.digest(@invalid_3_file)).strip

    assert_equal digest, 'HM1kfcoBN4Bfgr9b6Hc59bxFE3M='
  end

  def test_invalid_response_4_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    digest = Base64.encode64(sha1.digest(@invalid_4_file)).strip

    assert_equal digest, '/LEwhGmdHv2ynOG+Y0AYcgy+sjA='
  end

  def test_valid_responses_should_verify
    assert_equal @valid_1.soap_hashes_match?, true
    assert_equal @valid_2.soap_hashes_match?, true
    assert_equal @valid_3.soap_hashes_match?, true
    assert_equal @valid_4.soap_hashes_match?, true
  end

  def test_should_fail_with_invalid_responses
    assert_equal @invalid_1.soap_hashes_match?, false
    assert_equal @invalid_2.soap_hashes_match?, false
    assert_equal @invalid_3.soap_hashes_match?, false
    assert_equal @invalid_4.soap_hashes_match?, false
  end
end
