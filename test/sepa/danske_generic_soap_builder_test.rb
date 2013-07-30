require File.expand_path('../../test_helper.rb', __FILE__)

class DanskeGenericSoapBuilderTest < MiniTest::Test
  def setup
    @schemapath = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)
    @templatepath = File.expand_path('../../../lib/sepa/xml_templates/soap',__FILE__)
    @danske_keys_path = File.expand_path('../danske_test_keys', __FILE__)

    @danskecertparams = get_danske_cert_params
    @danskecertparams[:command] = :download_file

    @certrequest = Sepa::SoapBuilder.new(@danskecertparams)

    @xml = Nokogiri::XML(@certrequest.to_xml_unencrypted_generic)
  end

  def test_should_initialize_request_with_proper_params
    assert Sepa::SoapBuilder.new(@danskecertparams).to_xml
  end

  def test_should_fail_if_language_missing
    @danskecertparams.delete(:language)
    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@danskecertparams).to_xml
    end
  end

  def test_should_fail_if_target_id_missing
    @danskecertparams.delete(:target_id)
    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@danskecertparams).to_xml
    end
  end

end