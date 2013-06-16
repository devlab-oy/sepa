require File.expand_path('../../test_helper.rb', __FILE__)

class ApplicationResponseTest < MiniTest::Test
  def setup
    responses_path = File.expand_path('../test_files/test_responses', __FILE__)

    @dfl = Nokogiri::XML(File.read("#{responses_path}/dfl.xml"))
    @dfl = Sepa::Response.new(@dfl).application_response
  end

  def test_should_initialize_with_proper_params
    Sepa::ApplicationResponse.new(@dfl)
  end
end
