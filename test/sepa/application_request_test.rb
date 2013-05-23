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

    @ar = Sepa::ApplicationRequest.new(@params)

    @doc = Nokogiri::XML(Base64.decode64(@ar.get_as_base64))
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

  def test_should_have_customer_id_set
    assert_equal @doc.at_css("CustomerId").content, '11111111'
  end

  def test_should_have_timestamp_set
    timestamp = Time.strptime(@doc.at_css("Timestamp").content, '%Y-%m-%dT%H:%M:%S%z')
    assert timestamp <= Time.now && timestamp > (Time.now - 60), "Timestamp was not set correctly"
  end
end