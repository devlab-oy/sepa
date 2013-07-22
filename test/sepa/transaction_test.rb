require File.expand_path('../../test_helper.rb', __FILE__)

class TestTransaction < MiniTest::Test
  def setup
    @params = {
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

    @transaction = Sepa::Transaction.new(@params)
    @transaction_xml = Nokogiri::XML(@transaction.to_xml)
  end

  def test_should_initialize_with_proper_params
    assert Sepa::Transaction.new(@params)
  end

  def test_instruction_id_is_set_correctly
    assert_equal @params[:instruction_id],
      @transaction_xml.at_css("InstrId").content
  end
end
