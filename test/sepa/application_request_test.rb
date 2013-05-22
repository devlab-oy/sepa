require_relative '../test_helper'

class TestApplicationRequest < MiniTest::Unit::TestCase
  def setup
    @params = {
      private_key: 'sepa/nordea_testing/keys/nordea.key',
      cert: 'sepa/nordea_testing/keys/nordea.crt',
      command: :download_file,
      customer_id: '11111111',
      environment: 'PRODUCTION',
      status: 'NEW',
      target_id: '11111111A1',
      language: 'FI',
      file_type: 'TITO',
      wsdl: 'sepa/wsdl/wsdl_nordea.xml',
      content: payload,
      file_reference: "11111111A12006030329501800000014"
    }
    @ar = Sepa::ApplicationRequest.new(@params)
  end

  def load_should_succeed_with_proper_command
    assert @ar.load.respond.to?(:to_xml)
  end
end