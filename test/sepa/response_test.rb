require File.expand_path('../../test_helper.rb', __FILE__)

class ResponseTest < MiniTest::Test
  def setup
    @test_response = File.read(File.expand_path('../test_files/response.xml',
                                                __FILE__))

    @response_xml = Nokogiri::XML(@test_response)

    @response = Sepa::Response.new(@response_xml)
  end

  def test_should_initialize_with_proper_params
    assert Sepa::Response.new(@response_xml)
  end

  def test_test_response_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    digest = Base64.encode64(sha1.digest(@test_response)).strip

    assert_equal digest, 'vp0OeOELDa1V40/erOR6TgzmkdI='
  end

  def test_test_response_should_verify
    assert_equal @response.soap_hashes_match?, true
  end
end
