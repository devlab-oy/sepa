require File.expand_path('../../test_helper.rb', __FILE__)

class DanskeGetBankCertTest < ActiveSupport::TestCase
  def setup
    @schemas_path = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)

    @params = {
      bank: :danske,
      command: :get_bank_certificate,
      bank_root_cert_serial: '1111110002',
      customer_id: '360817'
    }

    @doc = Sepa::SoapBuilder.new(@params)
    @doc = Nokogiri::XML(@doc.to_xml)

    # Namespaces
    @pkif = 'http://danskebank.dk/PKI/PKIFactoryService'
    @elem = 'http://danskebank.dk/PKI/PKIFactoryService/elements'
  end

  def test_should_initialize_request_with_proper_params
    assert Sepa::SoapBuilder.new(@params).to_xml
  end

  def test_should_get_error_if_bank_missing
    @params.delete(:bank)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params)
    end
  end

  def test_should_get_error_if_command_missing
    @params.delete(:command)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params)
    end
  end

  def test_should_get_error_if_customer_id_missing
    @params.delete(:customer_id)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params)
    end
  end

  def test_should_get_error_if_bank_root_cert_cerial_missing
    @params.delete(:bank_root_cert_serial)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params)
    end
  end

  def test_sender_id_is_properly_set
    assert_equal @params[:customer_id],
      @doc.at('SenderId', 'xmlns' => @pkif).content
  end

  def test_customer_id_is_properly_set
    assert_equal @params[:customer_id],
      @doc.at('CustomerId', 'xmlns' => @pkif).content
  end

  def test_header_request_id_is_properly_set
    request_id = @doc.at("RequestId", 'xmlns' => @pkif).content

    assert request_id =~ /^[0-9A-F]+$/i
    assert_equal request_id.length, 10
  end

  def test_header_timestamp_is_set_correctly
    timestamp = @doc.at("Timestamp", 'xmlns' => @pkif).content
    timestamp = Time.strptime(timestamp, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= Time.now && timestamp > (Time.now - 60)
  end

  def test_interface_version_is_correctly_set
    version = @doc.at('InterfaceVersion', 'xmlns' => @pkif).content
    assert version.length >= 1 && version.length <= 10
  end

  def test_bank_root_cert_serial_is_correctly_set
    assert_equal @params[:bank_root_cert_serial],
      @doc.at('BankRootCertificateSerialNo', 'xmlns' => @elem).content
  end

  def test_request_timestamp_is_set_correctly
    timestamp = @doc.at("Timestamp", 'xmlns' => @elem).content
    timestamp = Time.strptime(timestamp, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= Time.now && timestamp > (Time.now - 60)
  end

  def test_request_request_id_is_properly_set
    request_id = @doc.at("RequestId", 'xmlns' => @elem).content

    assert request_id =~ /^[0-9A-F]+$/i
    assert_equal request_id.length, 10
  end

  def test_should_validate_against_soap_schema
    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(@doc)
    end
  end

  def test_request_should_validate_against_pki_service_schema
    request = @doc.css('GetBankCertificateRequest', 'xmlns' => @elem).to_xml
    request = Nokogiri::XML(request)

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('PKIFactory.xsd'))
      assert xsd.valid?(request)
    end
  end

  def test_invalid_bank_root_cert_serial_should_fail_schema_validation
    @doc.at('BankRootCertificateSerialNo', 'xmlns' => @elem).content = '1'*65

    request = @doc.css('GetBankCertificateRequest', 'xmlns' => @elem).to_xml
    request = Nokogiri::XML(request)

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('PKIFactory.xsd'))
      refute xsd.valid?(request)
    end
  end
end
