require File.expand_path('../../test_helper.rb', __FILE__)

class TestPayload < MiniTest::Test
  def setup
    @schemas_path = File.expand_path('../../../lib/sepa/xml_schemas', __FILE__)
    @params = {
      name: 'Testi Yhtio Oy',
      address: 'Testikatu 45',
      country: 'Finland',
      postcode: '00100',
      town: 'Helsinki'
    }
    @payload = Sepa::Payload.new(@params)
  end

  def test_should_initialize_with_hash
    assert Sepa::Payload.new(@params)
  end

  def test_validates_against_schema
    xsd = Nokogiri::XML::Schema(
      File.read("#{@schemas_path}/pain.001.001.02.xsd")
    )
    doc = Nokogiri::XML(@payload.to_xml)
    xsd.validate(doc).each do |error|
      puts error.message
    end
  end
end
