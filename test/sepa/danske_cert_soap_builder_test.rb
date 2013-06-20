require File.expand_path('../../test_helper.rb', __FILE__)

class DanskeCertSoapBuilderTest < MiniTest::Test
  def setup
    @schemapath = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)
    @templatepath = File.expand_path('../../../lib/sepa/xml_templates/soap',__FILE__)
    @danske_keys_path = File.expand_path('../danske_test_keys', __FILE__)

    reqid = SecureRandom.random_number(1000).to_s<<SecureRandom.random_number(1000).to_s

    @danskecertparams = {
      bank: :danske,
      command: :create_certificate,
      wsdl: File.expand_path('../../../lib/sepa/wsdl/wsdl_danske_cert.xml',__FILE__),
      request_id: reqid,
      customer_id: 'ABC123',
      environment: 'customertest',
      key_generator_type: 'software',
      encryption_cert_pkcs10: OpenSSL::X509::Request.new(File.read ("#{@danske_keys_path}/encryption_pkcs.csr")).to_der,
      signing_cert_pkcs10: OpenSSL::X509::Request.new(File.read ("#{@danske_keys_path}/signing_pkcs.csr")).to_der,
      cert: OpenSSL::X509::Certificate.new(File.read ("#{@danske_keys_path}/danskeroot.pem")),
      pin: '1234'
    }

    @certrequest = Sepa::SoapBuilder.new(@danskecertparams)

    @xml = Nokogiri::XML(@certrequest.to_xml_unencrypted)
  end

  def test_that_get_certificate_soap_template_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    template = File.read("#{@templatepath}/create_certificate.xml")
    digest = Base64.encode64(sha1.digest(template)).strip
    assert_equal digest, "OpPHtB1oqAmj2N7R0iD31MrApy0="
  end

  def test_should_initialize_with_proper_params
    assert Sepa::SoapBuilder.new(@danskecertparams)
  end

  def test_should_fail_with_wrong_command
    @danskecertparams.delete(:command)

    assert_raises(ArgumentError) { Sepa::SoapBuilder.new(@danskecertparams) }
  end

  def test_request_should_find_xmlenc_structure_when_request_encrypted
    xml = Nokogiri::XML(@certrequest.to_xml)

    xml.remove_namespaces!
    ar_node = xml.xpath("//EncryptedData").first

    assert ar_node.respond_to?(:canonicalize)
    assert_equal ar_node.at_css("EncryptionMethod")["Algorithm"], "http://www.w3.org/2001/04/xmlenc#tripledes-cbc"
  end

  def test_should_get_error_if_command_missing
    @danskecertparams.delete(:command)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@danskecertparams)
    end
  end

  def test_should_get_error_if_customer_id_missing
    @danskecertparams.delete(:customer_id)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@danskecertparams)
    end
  end

  def test_should_load_correct_template_with_get_certificate
    @danskecertparams[:command] = :create_certificate
    xml = Nokogiri::XML(Sepa::SoapBuilder.new(@danskecertparams).to_xml_unencrypted)

    assert xml.xpath('//tns:CreateCertificateRequest', 'tns' => 'http://danskebank.dk/PKI/PKIFactoryService/elements').first, "Path/namespace not found"
  end

  def test_should_raise_error_if_command_not_correct
    @danskecertparams[:command] = :wrong_command
    # This will be KeyError until different way to choose between soap/certrequests is implemented in applicationrequest class
    assert_raises(ArgumentError) do
      soap = Sepa::SoapBuilder.new(@danskecertparams).to_xml
    end
  end

  def test_timestamp_is_set_correctly
    timestamp_node = @xml.xpath(
      "//tns:Timestamp", 'tns' => 'http://danskebank.dk/PKI/PKIFactoryService/elements'
    ).first

    timestamp = Time.strptime(timestamp_node.content, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= Time.now && timestamp > (Time.now - 60)
  end

  def test_request_id_is_set_correctly
    request_id_node = @xml.xpath(
      "//tns:RequestId", 'tns' => 'http://danskebank.dk/PKI/PKIFactoryService/elements'
    ).first

    request_id = request_id_node.content.to_i

    assert request_id.kind_of?(Integer), "Request id should be a number"
    assert request_id != 0, "Request id can't be 0"
  end

  def test_should_validate_against_schema
    Dir.chdir(@schemapath) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(@xml)
    end
  end
end
