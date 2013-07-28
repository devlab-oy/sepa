require File.expand_path('../../test_helper.rb', __FILE__)

class TestPayload < MiniTest::Test
  def setup
    @schemas_path = File.expand_path('../../../lib/sepa/xml_schemas', __FILE__)

    trans_1_params = {
      instruction_id: '70CEF29BEBA8396A1F806005EDA51DEE4CE',
      end_to_end_id: '629CADFDAD5246AD915BA24A3C8E9FC3313',
      amount: '30.75',
      currency: 'EUR',
      bic: 'NDEAFIHH',
      name: 'Testi Saaja Oy',
      address: 'Kokeilukatu 66',
      country: 'FI',
      postcode: '00200',
      town: 'Helsinki',
      iban: 'FI7429501800000014',
      reference: '00000000000000001245',
      message: 'Maksu'
    }

    trans_2_params = {
      instruction_id: 'A552D3EBB207B4AC17DF97C7D548A0571B0',
      end_to_end_id: 'CDE1206C8745D6FBDCD2BBB02DB6CB6D3BE',
      amount: '1075.20',
      currency: 'EUR',
      bic: 'NDEAFIHH',
      name: 'Testing Company',
      address: 'Tynnyrikatu 56',
      country: 'FI',
      postcode: '00600',
      town: 'Helsinki',
      iban: 'FI7429501800000014',
      reference: '000000000000000034795',
      message: 'Siirto'
    }

    trans_3_params = {
      instruction_id: '44DB2850ABDFBEF2A32D0EE511BE5AB0B79',
      end_to_end_id: 'A107CF858A22116D0C8EC1E78B078794B8C',
      amount: '10000',
      currency: 'EUR',
      bic: 'NDEAFIHH',
      name: 'Best Company Ever',
      address: 'Banaanikuja 66',
      country: 'FI',
      postcode: '00900',
      town: 'Helsinki',
      iban: 'FI7429501800000014',
      reference: '000000000000000013247',
      message: 'Valuutan siirto toiselle tilille'
    }

    trans_4_params = {
      instruction_id: '16A0C311AF72F3F5E8B6704EB3B6086047C',
      end_to_end_id: 'B10CE2EC71DB76114DDA68C9DAAA77A59DB',
      amount: '12',
      currency: 'EUR',
      bic: 'NDEAFIHH',
      name: 'Testi Saaja Oy',
      address: 'Kokeilukatu 66',
      country: 'FI',
      postcode: '00200',
      town: 'Helsinki',
      iban: 'FI7429501800000014',
      reference: '00000000000000001245',
      message: 'Palkka heinakuulta',
      salary: true,
      social_security_number: '112233-0000'
    }

    trans_5_params = {
      instruction_id: 'E0C01A8D65EA0BAB7CF1D4337FBCC3D33D7',
      end_to_end_id: 'B10CE2EC71DB76114DDA68C9DAAA77A59DB',
      amount: '99.20',
      currency: 'EUR',
      bic: 'NDEAFIHH',
      name: 'Testing Company',
      address: 'Tynnyrikatu 56',
      country: 'FI',
      postcode: '00600',
      town: 'Helsinki',
      iban: 'FI7429501800000014',
      reference: '000000000000000034795',
      message: 'Elake',
      pension: true
    }

    trans_6_params = {
      instruction_id: 'FD19CD1844B20B0E65E66EA307668B1C3F8',
      end_to_end_id: 'CE9FF7E7CE5961AA1207C828DBFE467182F',
      amount: '15000',
      currency: 'EUR',
      bic: 'NDEAFIHH',
      name: 'Best Company Ever',
      address: 'Banaanikuja 66',
      country: 'FI',
      postcode: '00900',
      town: 'Helsinki',
      iban: 'FI7429501800000014',
      reference: '000000000000000013247',
      message: 'Palkka ajalta 15.6.2013 - 30.6.2013',
      salary: true,
      social_security_number: '112233-0001'
    }

    @debtor = {
      name: 'Testi Maksaja Oy',
      address: 'Testing Street 12',
      country: 'FI',
      postcode: '00100',
      town: 'Helsinki',
      customer_id: '0987654321',
      y_tunnus: '7391834327',
      iban: 'FI4819503000000010',
      bic: 'NDEAFIHH'
    }

    payment_1_transactions = []
    payment_2_transactions = []

    payment_1_transactions.push(Sepa::Transaction.new(trans_1_params))
    payment_1_transactions.push(Sepa::Transaction.new(trans_2_params))
    payment_1_transactions.push(Sepa::Transaction.new(trans_3_params))

    payment_2_transactions.push(Sepa::Transaction.new(trans_4_params))
    payment_2_transactions.push(Sepa::Transaction.new(trans_5_params))
    payment_2_transactions.push(Sepa::Transaction.new(trans_6_params))

    payment_1_params = {
      payment_info_id: 'F56D46DDA136A981F58C05999479E768C92',
      execution_date: '2013-08-10',
      transactions: payment_1_transactions
    }

    payment_2_params = {
      payment_info_id: 'B60EECC432C306876FE3E23999DF7F43254',
      execution_date: '2013-08-15',
      salary_or_pension: true,
      transactions: payment_2_transactions
    }

    @payments = []

    @payments.push(Sepa::Payment.new(@debtor, payment_1_params))
    @payments.push(Sepa::Payment.new(@debtor, payment_2_params))

    @payload = Sepa::Payload.new(@debtor, @payments)
    @pay_noko = Nokogiri::XML(@payload.to_xml)

    @xmlns = 'urn:iso:std:iso:20022:tech:xsd:pain.001.001.02'
  end

  def test_should_initialize_with_proper_params
    assert Sepa::Payload.new(@debtor, @payments)
  end

  def test_validates_against_schema
    xsd = Nokogiri::XML::Schema(
      File.read("#{@schemas_path}/pain.001.001.02.xsd")
    )
    doc = Nokogiri::XML(@payload.to_xml)

    assert xsd.valid?(doc)
  end

  def test_debtor_name_is_added_correctly_to_group_header
    assert_equal @debtor[:name],
      @pay_noko.at("//xmlns:InitgPty/xmlns:Nm", 'xmlns' => @xmlns).content
  end

  def test_debtors_first_address_line_is_added_correctly_to_group_header
    assert_equal @debtor[:address],
    @pay_noko.at(
      "//xmlns:InitgPty/xmlns:PstlAdr/xmlns:AdrLine[1]", 'xmlns' => @xmlns
    ).content
  end

  def test_debtors_second_address_line_is_added_correctly_to_group_header
    assert_equal "#{@debtor[:country]}-#{@debtor[:postcode]}",
    @pay_noko.at(
      "//xmlns:InitgPty/xmlns:PstlAdr/xmlns:AdrLine[2]", 'xmlns' => @xmlns
    ).content
  end

  def test_debtors_street_name_is_added_correctly_to_group_header
    assert_equal @debtor[:address],
    @pay_noko.at(
      "//xmlns:InitgPty/xmlns:PstlAdr/xmlns:StrtNm", 'xmlns' => @xmlns
    ).content
  end

  def test_debtors_postcode_is_added_correctly_to_group_header
    assert_equal "#{@debtor[:country]}-#{@debtor[:postcode]}",
    @pay_noko.at(
      "//xmlns:InitgPty/xmlns:PstlAdr/xmlns:PstCd", 'xmlns' => @xmlns
    ).content
  end

  def test_debtors_town_is_added_correctly_to_group_header
    assert_equal @debtor[:town],
    @pay_noko.at(
      "//xmlns:InitgPty/xmlns:PstlAdr/xmlns:TwnNm", 'xmlns' => @xmlns
    ).content
  end

  def test_debtors_country_is_added_correctly_to_group_header
    assert_equal @debtor[:country],
    @pay_noko.at(
      "//xmlns:InitgPty/xmlns:PstlAdr/xmlns:Ctry", 'xmlns' => @xmlns
    ).content
  end

  def test_nr_of_transactions_is_added_correctly_to_group_header
    assert_equal '6',
    @pay_noko.at(
      "//xmlns:GrpHdr/xmlns:NbOfTxs", 'xmlns' => @xmlns
    ).content
  end

  def test_should_raise_schema_error_if_doesnt_validate_against_schema
    @debtor[:name] = 'a'*71
    payload = Sepa::Payload.new(@debtor, @payments)
    assert_raises(SchemaError) { payload.to_xml }
  end
end
