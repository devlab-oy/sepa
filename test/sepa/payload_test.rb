require File.expand_path('../../test_helper.rb', __FILE__)

class TestPayload < MiniTest::Test
  def setup
    @schemas_path = File.expand_path('../../../lib/sepa/xml_schemas', __FILE__)
    @debtor = {
      name: 'Testi Maksaja Oy',
      address: 'Testikatu 45',
      country: 'FI',
      postcode: '00100',
      town: 'Helsinki',
      customer_id: '1234',
      y_tunnus: '1234',
      iban: 'GB29NWBK60161331926819',
      bic: 'NDEAFIHH'
    }

    @payment = {
      execution_date: Date.new.iso8601,
      payment_info_id: '123456789',
      payment_id: '987654321',
      end_to_end_id: '1234',
      amount: '30',
      currency: 'EUR',
      bic: 'GENODEFF'
    }
    @payload = Sepa::Payload.new(@debtor, @payment)
  end

  def test_should_initialize_with_hash
    assert Sepa::Payload.new(@debtor, @payment)
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
