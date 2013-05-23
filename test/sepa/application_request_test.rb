require_relative '../test_helper'

class TestApplicationRequest < MiniTest::Unit::TestCase
  def setup
    keys_path = File.expand_path('../nordea_test_keys', __FILE__)
    @xml_templates_path = File.expand_path('../../../lib/sepa/xml_templates/application_request', __FILE__)

    @params = {
      private_key: "#{keys_path}/nordea.key",
      cert: "#{keys_path}/nordea.crt",
      command: :download_file,
      customer_id: '11111111',
      environment: 'PRODUCTION',
      status: 'NEW',
      target_id: '11111111A1',
      language: 'FI',
      file_type: 'TITO',
      wsdl: 'sepa/wsdl/wsdl_nordea.xml',
      content: Base64.encode64("haisuli"),
      file_reference: "11111111A12006030329501800000014"
    }
  end

  def test_xml_templates_are_unmodified
    sha1 = OpenSSL::Digest::SHA1.new

    get_user_info_template = File.read("#{@xml_templates_path}/get_user_info.xml")
    download_file_list_template = File.read("#{@xml_templates_path}/download_file_list.xml")
    download_file_template = File.read("#{@xml_templates_path}/download_file.xml")
    upload_file_template = File.read("#{@xml_templates_path}/upload_file.xml")

    get_user_info_digest = sha1.digest(get_user_info_template)
    sha1.reset
    download_file_list_digest = sha1.digest(download_file_list_template)
    sha1.reset
    download_file_digest = sha1.digest(download_file_template)
    sha1.reset
    upload_file_digest = sha1.digest(upload_file_template)

    assert_equal Base64.encode64(get_user_info_digest).strip, "LW5J5R7SnPFPurAa2pM7weTWL1Y="
    assert_equal Base64.encode64(download_file_list_digest).strip, "dYtf4lOP1TXfXPVjYLvaTozhVrg="
    assert_equal Base64.encode64(download_file_digest).strip, "lY+8u+BhXlQmUyQiOiXcUfCUikc="
    assert_equal Base64.encode64(upload_file_digest).strip, "zRQTrNHkq4OLSX3u3ogxU05RJsI="
  end

  def test_ar_should_initialize_with_proper_params
    Sepa::ApplicationRequest.new(@params)
  end

  def test_load_should_return_XML_doc_with_proper_command
    commands = [:get_user_info, :download_file, :download_file_list, :upload_file]

    commands.each do |command|
      @params[:command] = command
      ar = Sepa::ApplicationRequest.new(@params)
      assert ar.load_template(@params[:command]).respond_to?(:canonicalize)
    end
  end

  def test_should_return_right_template_with_get_user_info
    template = File.read("#{@xml_templates_path}/get_user_info.xml")
    sha1 = OpenSSL::Digest::SHA1.new
    template_digest = sha1.digest(Nokogiri::XML(template))
    @params[:command] = :get_user_info
    ar = Sepa::ApplicationRequest.new(@params)
    sha1.reset
    loaded_digest = sha1.digest(ar.load_template(@params[:command]))
    assert_equal template_digest, loaded_digest
  end

  def test_should_return_right_template_with_download_file_list
    template = File.read("#{@xml_templates_path}/download_file_list.xml")
    sha1 = OpenSSL::Digest::SHA1.new
    template_digest = sha1.digest(Nokogiri::XML(template))
    @params[:command] = :download_file_list
    ar = Sepa::ApplicationRequest.new(@params)
    sha1.reset
    loaded_digest = sha1.digest(ar.load_template(@params[:command]))
    assert_equal template_digest, loaded_digest
  end

  def test_should_return_right_template_download_file
    template = File.read("#{@xml_templates_path}/download_file.xml")
    sha1 = OpenSSL::Digest::SHA1.new
    template_digest = sha1.digest(Nokogiri::XML(template))
    @params[:command] = :download_file
    ar = Sepa::ApplicationRequest.new(@params)
    sha1.reset
    loaded_digest = sha1.digest(ar.load_template(@params[:command]))
    assert_equal template_digest, loaded_digest
  end

  def test_should_return_right_template_with_upload_file
    template = File.read("#{@xml_templates_path}/upload_file.xml")
    sha1 = OpenSSL::Digest::SHA1.new
    template_digest = sha1.digest(Nokogiri::XML(template))
    @params[:command] = :upload_file
    ar = Sepa::ApplicationRequest.new(@params)
    sha1.reset
    loaded_digest = sha1.digest(ar.load_template(@params[:command]))
    assert_equal template_digest, loaded_digest
  end

  def test_load_should_raise_arg_err_when_bad_command
    ar = Sepa::ApplicationRequest.new(@params)
    assert_raises ArgumentError do
      ar.load_template(:wrongcommand)
    end
  end
end