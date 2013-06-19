require File.expand_path('../../test_helper.rb', __FILE__)

class AppResponseTest < MiniTest::Test
  def setup
    @exampleresponsepath = File.expand_path('../../../lib/sepa/nordea_testing/response',__FILE__)

    @parser = Sepa::ApplicationResponse.new
  end

  def test_that_053_example_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    template = File.read("#{@exampleresponsepath}/content_053.xml")
    digest = Base64.encode64(sha1.digest(template)).strip
    assert_equal digest, "kfgZav//JsPs+tLG8XrE2Sn+aT0="
  end

  def test_that_054_example_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    template = File.read("#{@exampleresponsepath}/content_054.xml")
    digest = Base64.encode64(sha1.digest(template)).strip
    assert_equal digest, "flXaS2mlkdckXDUX0lWPuafEris="
  end

  def test_parsing_053_should_fail_when_empty_content_entered
    assert_raises(ArgumentError) {@parser.get_account_statement_content("")}
  end

  def test_parsing_054_should_fail_when_empty_content_entered
    assert_raises(ArgumentError) {@parser.get_debit_credit_notification_content("")}
  end

  def test_should_parse_content_from_response_when_parsing_download_file_response
    @parser.animate_response("#{@exampleresponsepath}/download_file_response.xml")
    assert_equal @parser.content.empty?, false
  end

  # def test_should_parse_content_from_response_when_parsing_download_user_info_response
  #   @parser.animate_response("#{@exampleresponsepath}/download_file_response.xml")
  #   assert @parser.
  # end

  def test_should_return_hash_from_053_request
    assert @parser.get_account_statement_content("#{@exampleresponsepath}/content_053.xml").kind_of?(Hash), "Does not return a hash"
    assert @parser.get_account_statement_content("#{@exampleresponsepath}/content_053.xml").length > 0, "Hash should not be empty"
  end

  def test_should_return_hash_from_054_request
    assert @parser.get_debit_credit_notification_content("#{@exampleresponsepath}/content_054.xml").kind_of?(Hash), "Does not return a hash"
    assert @parser.get_debit_credit_notification_content("#{@exampleresponsepath}/content_054.xml").length > 0, "Hash should not be empty"
  end

  def test_method_listnewdescriptors_should_return_array_of_descriptors_when_parsing_download_file_list
    @parser.animate_response("#{@exampleresponsepath}/download_filelist_response.xml")
    assert @parser.list_new_descriptors.kind_of?(Array), "Type not an array" # Array can be empty
  end

  def test_method_listdescriptors_should_return_array_of_descriptors_when_parsing_download_file_list
    @parser.animate_response("#{@exampleresponsepath}/download_filelist_response.xml")
    assert @parser.list_all_descriptors.kind_of?(Array), "Type not an array"
    assert @parser.list_all_descriptors.length > 0, "Array should not be empty"
  end
end