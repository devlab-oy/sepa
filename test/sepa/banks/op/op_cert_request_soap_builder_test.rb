require 'test_helper'

class OpCertRequestSoapBuilderTest < ActiveSupport::TestCase

  def setup
    @params  = op_get_certificate_params
    @request = Sepa::SoapBuilder.new(@params)
    @xml     = Nokogiri::XML(@request.to_xml)
  end

  test "error is raised if command is missing" do
    @params.delete(:command)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params)
    end
  end

  test "correct template is loaded" do
    @params[:command] = :get_certificate
    xml               = Nokogiri::XML(Sepa::SoapBuilder.new(@params).to_xml)

    assert xml.xpath('//opc:getCertificatein', opc: OP_PKI).first
  end

  test "error is raised if command is not correct" do
    @params[:command] = :wrong_command
    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params).to_xml
    end
  end

  test "timestamp is set correctly" do
    timestamp_node = @xml.xpath("//opc:Timestamp", opc: OP_PKI).first

    timestamp = Time.strptime(timestamp_node.content, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= Time.now && timestamp > (Time.now - 60)
  end

  test "application request is inserted properly" do
    ar_node = @xml.xpath("//opc:ApplicationRequest", opc: OP_PKI).first

    ar_doc = Nokogiri::XML(decode(ar_node.content))

    assert ar_doc.respond_to?(:canonicalize)
    assert_equal ar_doc.at_css("CustomerId").content, @params[:customer_id]
  end

  test "validates against schema" do
    errors = []

    Dir.chdir(SCHEMA_PATH) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      xsd.validate(@xml).each do |error|
        errors << error
      end
    end

    assert errors.empty?, "The following schema validations failed:\n#{errors.join("\n")}"
  end
end
