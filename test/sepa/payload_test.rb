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
    }

    @trans_1_params = {
      instruction_id: '987654321',
      end_to_end_id: '20130722-E000001',
      amount: '30',
      currency: 'EUR',
      bic: 'NDEAFIHH',
      name: 'Testi Saaja Oy',
      address: 'Kokeilukatu 66',
      country: 'FI',
      postcode: '00200',
      town: 'Helsinki',
      iban: 'FI7429501800000014',
      reference: '123',
      message: 'Moikka'
    }

    @trans_2_params = {
      instruction_id: '18716416',
      end_to_end_id: '20130722-E000003',
      amount: '75',
      currency: 'EUR',
      bic: 'NDEAFIHH',
      name: 'Test Receiver Ltd.',
      address: 'Kokeilukatu 14',
      country: 'FI',
      postcode: '00500',
      town: 'Helsinki',
      iban: 'FI7429502500000085',
      reference: '681766',
      message: 'Heippa'
    }

    @transaction_1 = Sepa::Transaction.new(@trans_1_params)
    @transaction_2 = Sepa::Transaction.new(@trans_2_params)

    @transactions = [@transaction_1, @transaction_2]

    @payload = Sepa::Payload.new(@debtor, @payment, @transactions)
    @pay_noko = Nokogiri::XML(@payload.to_xml)
  end

  def test_should_initialize_with_proper_params
    assert Sepa::Payload.new(@debtor, @payment, @transactions)
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
