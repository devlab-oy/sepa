require File.expand_path('../../test_helper.rb', __FILE__)

class ApplicationResponseTest < MiniTest::Test
  def setup
    responses_path = File.expand_path('../test_files/test_responses', __FILE__)

    @dfl = Nokogiri::XML(File.read("#{responses_path}/dfl.xml"))
    @dfl = Sepa::Response.new(@dfl).application_response

    @uf = Nokogiri::XML(File.read("#{responses_path}/uf.xml"))
    @uf = Sepa::Response.new(@uf).application_response

    @df = Nokogiri::XML(File.read("#{responses_path}/df.xml"))
    @df = Sepa::Response.new(@df).application_response

    @gui = Nokogiri::XML(File.read("#{responses_path}/gui.xml"))
    @gui = Sepa::Response.new(@gui).application_response
  end

  def test_should_initialize_with_proper_params
    assert Sepa::ApplicationResponse.new(@dfl)
    assert Sepa::ApplicationResponse.new(@uf)
    assert Sepa::ApplicationResponse.new(@df)
    assert Sepa::ApplicationResponse.new(@gui)
  end

  def test_should_complain_if_initialized_with_something_not_nokogiri_xml
    assert_raises(ArgumentError) { Sepa::ApplicationResponse.new("Jees") }
  end

  def test_should_complain_if_response_not_valid_against_schema
    assert_raises(ArgumentError) do
      Sepa::ApplicationResponse.new(Nokogiri::XML("<ar>text</ar>"))
    end
  end
end
