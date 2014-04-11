require File.expand_path('../../test_helper.rb', __FILE__)

class NordeaCertRequestSoapBuilderTest < ActiveSupport::TestCase
  def setup
    @schemapath = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)
    @templatepath = File.expand_path('../../../lib/sepa/xml_templates/soap',__FILE__)
    @keyspath = File.expand_path('../nordea_test_keys', __FILE__)

    @params = get_cert_params

    @certrequest = Sepa::SoapBuilder.new(@params)

    @xml = Nokogiri::XML(@certrequest.to_xml)
  end

  def test_should_fail_if_bank_doesnt_support_command
    @params[:command] = :create_certificate

    assert_raises(ArgumentError) { Sepa::SoapBuilder.new(@params) }
  end

  def test_that_get_certificate_soap_template_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    template = File.read("#{@templatepath}/get_certificate.xml")
    digest = Base64.encode64(sha1.digest(template)).strip

    assert_equal digest, "iYJcoQAlXZj5Pp9vLlSROXxY3+k="
  end

  def test_should_initialize_with_proper_params
    assert Sepa::SoapBuilder.new(@params)
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

  def test_should_load_correct_template_with_get_certificate
    @params[:command] = :get_certificate
    xml = Nokogiri::XML(Sepa::SoapBuilder.new(@params).to_xml)

    assert xml.xpath('//cer:getCertificatein', 'cer' => 'http://bxd.fi/CertificateService').first
  end

  def test_should_raise_error_if_command_not_correct
    @params[:command] = :wrong_command
    assert_raises(ArgumentError) do
      soap = Sepa::SoapBuilder.new(@params).to_xml
    end
  end

  def test_timestamp_is_set_correctly
    timestamp_node = @xml.xpath(
      "//cer:Timestamp", 'cer' => 'http://bxd.fi/CertificateService'
    ).first

    timestamp = Time.strptime(timestamp_node.content, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= Time.now && timestamp > (Time.now - 60)
  end

  def test_application_request_should_be_inserted_properly
    ar_node = @xml.xpath(
      "//cer:ApplicationRequest", 'cer' => 'http://bxd.fi/CertificateService'
    ).first

    ar_doc = Nokogiri::XML(Base64.decode64(ar_node.content))

    assert ar_doc.respond_to?(:canonicalize)
    assert_equal ar_doc.at_css("CustomerId").content, @params[:customer_id]
  end

  def test_should_validate_against_schema
    Dir.chdir(@schemapath) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(@xml)
    end
  end
end
