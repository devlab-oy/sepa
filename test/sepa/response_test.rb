require File.expand_path('../../test_helper.rb', __FILE__)

class ResponseTest < MiniTest::Test
  def setup
    @response_xml = Nokogiri::XML(
      File.read(File.expand_path('../test_files/response.xml',
                                 __FILE__))
    )

    @response = Sepa::Response.new(@response_xml)
  end

  def test_should_initialize_with_proper_params
    assert Sepa::Response.new(@response_xml)
  end

  def test_should_verify_soap_digests
    assert_equal @response.verify_soap_digests, true
  end
end
