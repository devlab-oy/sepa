require File.expand_path('../../test_helper.rb', __FILE__)

class DanskeGenericSoapBuilderTest < MiniTest::Test
  def setup
    @schemas_path = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)
    @templatepath = File.expand_path('../../../lib/sepa/xml_templates/soap',__FILE__)
    keys_path = File.expand_path('../danske_test_keys', __FILE__)

    private_key_path = "#{keys_path}/signing_private_key.pem"
    signing_cert_path = "#{keys_path}/own_signing_cert.pem"
    enc_cert_path = "#{keys_path}/bank_encryption_cert.pem"

    @params = {
      bank: :danske,
      private_key_path: private_key_path,
      command: :upload_file,
      customer_id: '360817',
      environment: 'TEST',
      enc_cert_path: enc_cert_path,
      cert_path: signing_cert_path,
      language: 'EN',
      status: 'ALL',
      target_id: 'Danske FI',
      file_type: 'pain.001.001.02',
      content: Base64.encode64('kissa')
    }

    @soap_request = Sepa::SoapBuilder.new(@params)

    @doc = Nokogiri::XML(@soap_request.to_xml)
  end

  def test_should_initialize_request_with_proper_params
    assert Sepa::SoapBuilder.new(@params).to_xml
  end

  def test_should_fail_if_language_missing
    @params.delete(:language)
    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params).to_xml
    end
  end

  def test_should_fail_if_target_id_missing
    @params.delete(:target_id)
    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params).to_xml
    end
  end

  def test_should_validate_against_schema
    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(@doc)
    end
  end

  def test_schema_validation_should_fail_with_wrong_must_understand_value
    security_node = @doc.at(
      '//wsse:Security', 'wsse' => 'http://docs.oasis-open.org/wss/2004/01/oa' \
      'sis-200401-wss-wssecurity-secext-1.0.xsd'
    )

    security_node['env:mustUnderstand'] = '3'

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      refute xsd.valid?(@doc)
    end
  end

  def test_should_validate_against_ws_security_schema
    ws_node = @doc.xpath(
      '//wsse:Security', 'wsse' => 'http://docs.oasis-open.org/wss/2004/01/' \
      'oasis-200401-wss-wssecurity-secext-1.0.xsd'
    )

    ws_node = ws_node.to_xml

    ws_node = Nokogiri::XML(ws_node)

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema IO.read 'oasis-200401-wss-wssecurity-' \
        'secext-1.0.xsd'
      assert xsd.valid?(ws_node)
    end
  end
end
