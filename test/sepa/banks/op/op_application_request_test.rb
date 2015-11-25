require 'test_helper'

class OpApplicationRequestTest < ActiveSupport::TestCase
  def setup
    @params = op_generic_params

    # Convert the keys here since the conversion is usually done by the client and these tests
    # bypass the client
    @params[:signing_private_key]     = rsa_key @params[:signing_private_key]
    @params[:own_signing_certificate] = x509_certificate @params[:own_signing_certificate]

    ar_file = Sepa::SoapBuilder.new(@params).application_request

    @params[:command] = :download_file_list
    ar_list           = Sepa::SoapBuilder.new(@params).application_request

    @params[:command] = :upload_file
    ar_up             = Sepa::SoapBuilder.new(@params).application_request

    @doc_file = Nokogiri::XML(ar_file.to_xml)
    @doc_list = Nokogiri::XML(ar_list.to_xml)
    @doc_up   = Nokogiri::XML(ar_up.to_xml)
  end

  test 'download file validates against schema' do
    errors = []

    Dir.chdir(SCHEMA_PATH) do
      xsd = Nokogiri::XML::Schema(IO.read('op/ApplicationRequest_20080918.xsd'))
      xsd.validate(@doc_file).each do |error|
        errors << error
      end
    end

    assert errors.empty?, "The following schema validations failed:\n#{errors.join("\n")}"
  end

  test 'upload file validates against schema' do
    errors = []

    Dir.chdir(SCHEMA_PATH) do
      xsd = Nokogiri::XML::Schema(IO.read('op/ApplicationRequest_20080918.xsd'))
      xsd.validate(@doc_up).each do |error|
        errors << error
      end
    end

    assert errors.empty?, "The following schema validations failed:\n#{errors.join("\n")}"
  end

  test 'download file list validates against schema' do
    errors = []

    Dir.chdir(SCHEMA_PATH) do
      xsd = Nokogiri::XML::Schema(IO.read('op/ApplicationRequest_20080918.xsd'))
      xsd.validate(@doc_list).each do |error|
        errors << error
      end
    end

    assert errors.empty?, "The following schema validations failed:\n#{errors.join("\n")}"
  end
end
