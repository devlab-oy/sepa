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
  end

  def test_should_initialize_with_proper_params
    assert Sepa::Response.new(@valid_1)
  end

  def test_valid_response_1_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    digest = Base64.encode64(sha1.digest(@valid_1_file)).strip

    assert_equal digest, 'vp0OeOELDa1V40/erOR6TgzmkdI='
  end

  def test_valid_responses_should_verify
    assert_equal @valid_1.soap_hashes_match?, true
    assert_equal @valid_2.soap_hashes_match?, true
    assert_equal @valid_3.soap_hashes_match?, true
    assert_equal @valid_4.soap_hashes_match?, true
  end
end
