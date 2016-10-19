require 'test_helper'

class NordeaCertRequestSoapBuilderTest < ActiveSupport::TestCase
  def setup
    @nordea_get_certificate_params = nordea_get_certificate_params
    @certrequest = Sepa::SoapBuilder.new(@nordea_get_certificate_params)
    @xml = Nokogiri::XML(@certrequest.to_xml)
  end

  def test_should_initialize_with_proper_params
    assert Sepa::SoapBuilder.new(@nordea_get_certificate_params)
  end

  def test_should_get_error_if_command_missing
    @nordea_get_certificate_params.delete(:command)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@nordea_get_certificate_params)
    end
  end

  def test_should_load_correct_template_with_get_certificate
    @nordea_get_certificate_params[:command] = :get_certificate
    xml = Nokogiri::XML(Sepa::SoapBuilder.new(@nordea_get_certificate_params).to_xml)

    assert xml.xpath('//cer:getCertificatein', 'cer' => 'http://bxd.fi/CertificateService').first
  end

  def test_should_raise_error_if_command_not_correct
    @nordea_get_certificate_params[:command] = :wrong_command
    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@nordea_get_certificate_params).to_xml
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

    ar_doc = Nokogiri::XML(decode(ar_node.content))

    assert ar_doc.respond_to?(:canonicalize)
    assert_equal ar_doc.at_css("CustomerId").content, @nordea_get_certificate_params[:customer_id]
  end

  def test_should_validate_against_schema
    assert_valid_against_schema 'soap.xsd', @xml
  end
end
