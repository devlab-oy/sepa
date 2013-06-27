require File.expand_path('../../test_helper.rb', __FILE__)

class DanskeGenericSoapBuilderTest < MiniTest::Test
  def setup
    @schemapath = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)
    @templatepath = File.expand_path('../../../lib/sepa/xml_templates/soap',__FILE__)
    @danske_keys_path = File.expand_path('../danske_test_keys', __FILE__)

    reqid = SecureRandom.random_number(1000).to_s<<SecureRandom.random_number(1000).to_s
    payload = "Helou"
    @danskecertparams = {
      bank: :danske,
      target_id: 'Danske FI',
      language: 'EN',
      command: :download_file,
      wsdl: File.expand_path('../../../lib/sepa/wsdl/wsdl_danske_cert.xml',__FILE__),
      request_id: reqid,
      customer_id: 'ABC123',
      environment: 'customertest',
      key_generator_type: 'software',
      private_key: OpenSSL::PKey::RSA.new(File.read("#{@danske_keys_path}/signing_key.pem")),
      cert: OpenSSL::X509::Certificate.new(File.read ("#{@danske_keys_path}/danskeroot.pem")),
      pin: '1234',
      content: payload,

    }

    @certrequest = Sepa::SoapBuilder.new(@danskecertparams)

    @xml = Nokogiri::XML(@certrequest.to_xml_unencrypted_generic)
  end

  def test_should_initialize_request_with_proper_params
    assert Sepa::SoapBuilder.new(@danskecertparams).to_xml
  end

  def test_should_fail_if_language_missing
    @danskecertparams.delete(:language)
    assert_raises(KeyError) do
      Sepa::SoapBuilder.new(@danskecertparams).to_xml
    end
  end

  def test_should_fail_if_target_id_missing
    @danskecertparams.delete(:target_id)
    assert_raises(KeyError) do
      Sepa::SoapBuilder.new(@danskecertparams).to_xml
    end
  end

end