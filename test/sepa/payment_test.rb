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

    @params = {
      payment_info_id: 'F56D46DDA136A981F58C05999479E768C92',
      execution_date: '2013-08-10',
      debtor_name: 'Testi Maksaja Oy',
      debtor_address: 'Testing Street 12',
      debtor_country: 'Finland',
      debtor_postcode: '00100',
      debtor_town: 'Helsinki'

    }

    transaction_1 = Sepa::Transaction.new(trans_1_params)
    transaction_2 = Sepa::Transaction.new(trans_2_params)
    transaction_3 = Sepa::Transaction.new(trans_3_params)
  end
end
