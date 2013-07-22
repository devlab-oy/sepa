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
      iban: 'FI4819503000000010',
      bic: 'NDEAFIHH'
    }

    @payment = {
      execution_date: Date.new.iso8601,
      payment_info_id: '123456789',
      payment_id: '987654321',
      end_to_end_id: '1234',
      amount: '30',
      currency: 'EUR',
      clearing: '',
      ref: '123',
      message: 'Moikka'
    }

    @creditor = {
      bic: 'NDEAFIHH',
      name: 'Testi Saaja Oy',
      address: 'Kokeilukatu 66',
      country: 'FI',
      postcode: '00200',
      town: 'Helsinki',
      iban: 'FI7429501800000014'
    }
    @payload = Sepa::Payload.new(@debtor, @payment, @creditor)
    @pay_noko = Nokogiri::XML(@payload.to_xml)
  end

  def test_should_initialize_with_hash
    assert Sepa::Payload.new(@debtor, @payment, @creditor)
  end

  def test_validates_against_schema
    xsd = Nokogiri::XML::Schema(
      File.read("#{@schemas_path}/pain.001.001.02.xsd")
    )
    doc = Nokogiri::XML(@payload.to_xml)
    assert xsd.valid?(doc)
  end

  def test_debtor_name_is_added_correctly_to_group_header
    assert_equal @pay_noko.at_css(
      "InitgPty > Nm",
      'xmlns' => 'urn:iso:std:iso:20022:tech:xsd:pain.001.001.02'
    ).content, @debtor[:name]
  end
end
