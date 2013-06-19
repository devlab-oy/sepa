require File.expand_path('../../test_helper.rb', __FILE__)

class AppResponseTest < MiniTest::Test
  def setup
    @exampleresponsepath = File.expand_path('../../../lib/sepa/nordea_testing/response',__FILE__)

    @parser = Sepa::ApplicationResponse.new
  end

  def test_should_create_objects_from_incoming_file
    @parser.animate_response("#{@exampleresponsepath}/download_file_response.xml")
    assert_equal @parser.content.empty?, false
  end

  def test_should_return_hash_from_053_request
    assert @parser.get_account_statement_content("#{@exampleresponsepath}/content_053.xml").kind_of?(Hash)
  end

  def test_should_return_hash_from_054_request
    assert @parser.get_debit_credit_notification_content("#{@exampleresponsepath}/content_054.xml").kind_of?(Hash)
  end
end