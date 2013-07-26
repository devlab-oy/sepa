require File.expand_path('../../test_helper.rb', __FILE__)

class TestPayment < MiniTest::Test
  def setup
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

    @debtor = {
      name: 'Testi Maksaja Oy',
      address: 'Testing Street 12',
      country: 'Finland',
      postcode: '00100',
      town: 'Helsinki',
      customer_id: '0987654321',
      y_tunnus: '7391834327',
      iban: 'FI4819503000000010',
      bic: 'NDEAFIHH'
    }

    transactions = []

    transactions.push(Sepa::Transaction.new(trans_1_params))
    transactions.push(Sepa::Transaction.new(trans_2_params))
    transactions.push(Sepa::Transaction.new(trans_3_params))

    @params = {
      payment_info_id: 'F56D46DDA136A981F58C05999479E768C92',
      execution_date: '2013-08-10',
      transactions: transactions
    }

    @payment = Sepa::Payment.new(@debtor, @params)

    @payment_node = @payment.to_node
  end

  def test_should_initialize_with_proper_params
    assert Sepa::Payment.new(@debtor, @params)
  end

  def test_payment_info_id_is_set_correctly
    assert_equal @params[:payment_info_id],
      @payment_node.at('/PmtInf/PmtInfId').content
  end

  def test_execution_date_is_set_correctly
    assert_equal @params[:execution_date],
      @payment_node.at('/PmtInf/ReqdExctnDt').content
  end

  def test_debtor_name_is_set_correctly
    assert_equal @debtor[:name],
      @payment_node.at('/PmtInf/Dbtr/Nm').content
  end

  def test_debtors_first_address_line_is_set_correctly
    assert_equal @debtor[:address],
      @payment_node.at('/PmtInf/Dbtr/PstlAdr/AdrLine[1]').content
  end

  def test_debtors_second_address_line_is_set_correctly
    assert_equal "#{@debtor[:country]}-#{@debtor[:postcode]} #{@debtor[:town]}",
      @payment_node.at('/PmtInf/Dbtr/PstlAdr/AdrLine[2]').content
  end

  def test_debtors_country_is_set_correctly
    assert_equal @debtor[:country],
      @payment_node.at('/PmtInf/Dbtr/PstlAdr/Ctry').content
  end

  def test_debtors_customer_id_is_set_when_present
    assert_equal @debtor[:customer_id],
      @payment_node.at('/PmtInf/Dbtr/Id/OrgId').content
  end

  def test_debtors_y_tunnus_is_set_when_customer_id_not_present
    @debtor.delete(:customer_id)

    payment = Sepa::Payment.new(@debtor, @params)
    payment_node = payment.to_node

    assert_equal @debtor[:y_tunnus],
      payment_node.at('/PmtInf/Dbtr/Id/OrgId').content
  end

  def test_debtors_iban_is_set_correctly
    assert_equal @debtor[:iban],
      @payment_node.at('/PmtInf/DbtrAcct/Id/IBAN').content
  end

  def test_debtors_bic_is_set_correctly
    assert_equal @debtor[:bic],
      @payment_node.at('/PmtInf/DbtrAgt/FinInstnId/BIC').content
  end

  def test_nr_of_transaction_elements_matches_the_nr_in_hash
    assert_equal @params[:transactions].count,
      @payment_node.xpath('/PmtInf/CdtTrfTxInf').count
  end
end
