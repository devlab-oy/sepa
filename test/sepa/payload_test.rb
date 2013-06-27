require File.expand_path('../../test_helper.rb', __FILE__)

class TestPayload < MiniTest::Test
  def setup
    @schemas_path = File.expand_path('../../../lib/sepa/xml_schemas', __FILE__)
    @params = {}
    @payload = Sepa::Payload.new(@params)
  end

  def test_should_initialize_with_hash
    assert Sepa::Payload.new(@params)
  end

  def test_payload_validates_as_proper_xml
    xsd = Nokogiri::XML::Schema(File.read("#{@schemas_path}/xml.xsd"))
    xml = Nokogiri::XML(@payload.to_xml)
    xsd.validate(xml).each do |error|
      puts error.message
    end
  end
end
