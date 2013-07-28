require File.expand_path('../../test_helper.rb', __FILE__)

class TestTransaction < MiniTest::Test
  def setup
    @invoice_bundle = []

    invoice_1 = {
      type: 'CINV',
      amount: '700',
      currency: 'EUR',
      invoice_number: '123456'
    }

    invoice_2 = {
      type: 'CINV',
      amount: '300',
      currency: 'EUR',
      reference: '123456789',
    }

    invoice_3 = {
      type: 'CREN',
      amount: '-100',
      currency: 'EUR',
      invoice_number: '654321'
    }

    invoice_4 = {
      type: 'CREN',
      amount: '-500',
      currency: 'EUR',
      reference: '987654321'
    }

    @invoice_bundle.push(invoice_1)
    @invoice_bundle.push(invoice_2)
    @invoice_bundle.push(invoice_3)
    @invoice_bundle.push(invoice_4)

    @params = {
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
      message: 'Maksu',
      social_security_number: '112233-0005'
    }

    @transaction = Sepa::Transaction.new(@params)
    @transaction_node = @transaction.to_node
  end

  def test_should_initialize_with_proper_params
    assert Sepa::Transaction.new(@params)
  end

  def test_instruction_id_is_set_correctly
    assert_equal @params[:instruction_id],
      @transaction_node.at('/CdtTrfTxInf/PmtId/InstrId').content
  end

  def test_end_to_end_id_is_set_correctly
    assert_equal @params[:end_to_end_id],
      @transaction_node.at('/CdtTrfTxInf/PmtId/EndToEndId').content
  end

  def test_amount_is_set_correctly
    assert_equal @params[:amount],
      @transaction_node.at('/CdtTrfTxInf/Amt/InstdAmt').content
  end

  def test_currency_is_set_correctly
    assert_equal @params[:currency],
      @transaction_node.at('/CdtTrfTxInf/Amt/InstdAmt/@Ccy').content
  end

  def test_bic_is_set_correctly
    assert_equal @params[:bic],
      @transaction_node.at('/CdtTrfTxInf/CdtrAgt/FinInstnId/BIC').content
  end

  def test_name_is_set_correctly
    assert_equal @params[:name],
      @transaction_node.at('/CdtTrfTxInf/Cdtr/Nm').content
  end

  def test_first_address_line_is_set_correctly
    assert_equal @params[:address],
      @transaction_node.at('/CdtTrfTxInf/Cdtr/PstlAdr/AdrLine[1]').content
  end

  def test_second_address_line_is_set_correctly
    assert_equal "#{@params[:country]}-#{@params[:postcode]} #{@params[:town]}",
      @transaction_node.at('/CdtTrfTxInf/Cdtr/PstlAdr/AdrLine[2]').content
  end

  def test_street_name_is_set_correctly
    assert_equal @params[:address],
      @transaction_node.at('/CdtTrfTxInf/Cdtr/PstlAdr/StrtNm').content
  end

  def test_postcode_is_set_correctly
    assert_equal "#{@params[:country]}-#{@params[:postcode]}",
      @transaction_node.at('/CdtTrfTxInf/Cdtr/PstlAdr/PstCd').content
  end

  def test_town_is_set_correctly
    assert_equal @params[:town],
      @transaction_node.at('/CdtTrfTxInf/Cdtr/PstlAdr/TwnNm').content
  end

  def test_country_is_set_correctly
    assert_equal @params[:country],
      @transaction_node.at('/CdtTrfTxInf/Cdtr/PstlAdr/Ctry').content
  end

  def test_iban_is_set_correctly
    assert_equal @params[:iban],
      @transaction_node.at('/CdtTrfTxInf/CdtrAcct/Id/IBAN').content
  end

  def test_reference_is_set_if_present
    assert_equal @params[:reference],
    @transaction_node.at(
      '/CdtTrfTxInf/RmtInf/Strd/CdtrRefInf/CdtrRef'
    ).content
  end

  def test_message_is_not_set_when_reference_is_present
    refute @transaction_node.at('/CdtTrfTxInf/RmtInf/Ustrd')
  end

  def test_message_is_set_when_reference_not_present
    @params.delete(:reference)

    transaction = Sepa::Transaction.new(@params)
    transaction_node = transaction.to_node

    assert_equal @params[:message],
      transaction_node.at('/CdtTrfTxInf/RmtInf/Ustrd').content
  end

  def test_social_security_number_is_set_correctly_when_salary
    @params[:salary] = true
    transaction = Sepa::Transaction.new(@params)
    transaction_node = transaction.to_node

    assert_equal @params[:social_security_number],
      transaction_node.at('/CdtTrfTxInf/Cdtr/Id/PrvtId/SclSctyNb').content
  end

  def test_purpose_is_set_correctly_when_pension
    @params[:pension] = true
    transaction = Sepa::Transaction.new(@params)
    transaction_node = transaction.to_node

    assert_equal transaction_node.at('/CdtTrfTxInf/Purp/Cd').content,
      'PENS'
  end

  def test_invoice_bundle_is_added_correctly
    @params[:invoice_bundle] = @invoice_bundle
    transaction = Sepa::Transaction.new(@params)
    transaction_node = transaction.to_node

    assert_equal @invoice_bundle.count,
      transaction_node.xpath('/CdtTrfTxInf/RmtInf/Strd').count
  end

  def test_raises_key_error_if_end_to_end_id_missing
    @params.delete(:end_to_end_id)
    assert_raises(KeyError) { transaction = Sepa::Transaction.new(@params) }
  end

  def test_raises_key_error_if_invoice_amount_missing
    @invoice_bundle[0].delete(:amount)
    @params[:invoice_bundle] = @invoice_bundle

    assert_raises(KeyError) { transaction = Sepa::Transaction.new(@params) }
  end

  def test_raises_key_error_if_invoice_type_missing
    @invoice_bundle[1].delete(:type)
    @params[:invoice_bundle] = @invoice_bundle
    transaction = Sepa::Transaction.new(@params)

    assert_raises(KeyError) { transaction.to_node }
  end

  def test_raises_key_error_if_amount_missing_when_not_invoice_bundle
    @params.delete(:amount)
    assert_raises(KeyError) { transaction = Sepa::Transaction.new(@params) }
  end

  def test_raises_key_error_if_currency_missing
    @params.delete(:currency)
    assert_raises(KeyError) { transaction = Sepa::Transaction.new(@params) }
  end

  def test_raises_key_error_if_bic_missing
    @params.delete(:bic)
    assert_raises(KeyError) { transaction = Sepa::Transaction.new(@params) }
  end

  def test_raises_key_error_if_name_missing
    @params.delete(:name)
    assert_raises(KeyError) { transaction = Sepa::Transaction.new(@params) }
  end

  def test_raises_key_error_if_address_missing
    @params.delete(:address)
    assert_raises(KeyError) { transaction = Sepa::Transaction.new(@params) }
  end

  def test_raises_key_error_if_country_missing
    @params.delete(:country)
    assert_raises(KeyError) { transaction = Sepa::Transaction.new(@params) }
  end

  def test_raises_key_error_if_postcode_missing
    @params.delete(:postcode)
    assert_raises(KeyError) { transaction = Sepa::Transaction.new(@params) }
  end

  def test_raises_key_error_if_town_missing
    @params.delete(:town)
    assert_raises(KeyError) { transaction = Sepa::Transaction.new(@params) }
  end

  def test_raises_key_error_if_iban_missing
    @params.delete(:iban)
    assert_raises(KeyError) { transaction = Sepa::Transaction.new(@params) }
  end
end
