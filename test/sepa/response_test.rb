require File.expand_path('../../test_helper.rb', __FILE__)

class ResponseTest < MiniTest::Test
  def setup
    @response = Nokogiri::XML(
      File.read(File.expand_path('../test_files/response.xml',
                                 __FILE__))
    )
  end
end
