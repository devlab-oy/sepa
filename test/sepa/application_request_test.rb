require_relative '../test_helper'

class TestApplicationRequest < MiniTest::Test
  def setup
    keys_path = File.expand_path('../nordea_test_keys', __FILE__)

    @xml_templates_path = File.expand_path(
    '../../../lib/sepa/xml_templates/application_request', __FILE__)

    @schemas_path = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)

    private_key = OpenSSL::PKey::RSA.new(File.read("#{keys_path}/nordea.key"))
    cert = OpenSSL::X509::Certificate.new(File.read("#{keys_path}/nordea.crt"))

    @params = {
      private_key: private_key,
      cert: cert,
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

    @ar_file = Sepa::ApplicationRequest.new(@params)

    @params[:command] = :get_user_info
    @ar_get = Sepa::ApplicationRequest.new(@params)

    @params[:command] = :download_file_list
    @ar_list = Sepa::ApplicationRequest.new(@params)

    @params[:command] = :upload_file
    @ar_up = Sepa::ApplicationRequest.new(@params)

    @doc_file = Nokogiri::XML(Base64.decode64(@ar_file.get_as_base64))
    @doc_get = Nokogiri::XML(Base64.decode64(@ar_get.get_as_base64))
    @doc_list = Nokogiri::XML(Base64.decode64(@ar_list.get_as_base64))
    @doc_up = Nokogiri::XML(Base64.decode64(@ar_up.get_as_base64))
  end

  # Just to make sure that the xml templates are unmodified because
  # the application logic is designed for exactly these templates
  def test_xml_templates_are_unmodified
    sha1 = OpenSSL::Digest::SHA1.new

    get_user_info_template = File.read(
    "#{@xml_templates_path}/get_user_info.xml")

    download_file_list_template = File.read(
    "#{@xml_templates_path}/download_file_list.xml")

    download_file_template = File.read(
    "#{@xml_templates_path}/download_file.xml")

    upload_file_template = File.read(
    "#{@xml_templates_path}/upload_file.xml")

    get_user_info_digest = Base64.encode64(
    sha1.digest(get_user_info_template)).strip

    sha1.reset

    download_file_list_digest = Base64.encode64(
    sha1.digest(download_file_list_template)).strip

    sha1.reset

    download_file_digest = sha1.digest(download_file_template)

    sha1.reset

    upload_file_digest = sha1.digest(upload_file_template)

    assert_equal get_user_info_digest, "LW5J5R7SnPFPurAa2pM7weTWL1Y="

    assert_equal download_file_list_digest.strip,
    "dYtf4lOP1TXfXPVjYLvaTozhVrg="

    assert_equal Base64.encode64(download_file_digest).strip,
    "lY+8u+BhXlQmUyQiOiXcUfCUikc="

    assert_equal Base64.encode64(upload_file_digest).strip,
    "zRQTrNHkq4OLSX3u3ogxU05RJsI="
  end

  def test_schemas_are_unmodified
    sha1 = OpenSSL::Digest::SHA1.new

    ar_schema = File.read(
    "#{@schemas_path}/application_request.xsd")

    xmldsig_schema = File.read(
    "#{@schemas_path}/xmldsig-core-schema.xsd")

    ar_schema_digest = sha1.digest(ar_schema)

    sha1.reset

    xmldsig_schema_digest = sha1.digest(xmldsig_schema)

    assert_equal Base64.encode64(ar_schema_digest).strip,
    "1O24A7+/6S7CFYVlhH1jEZh1ARs="

    assert_equal Base64.encode64(xmldsig_schema_digest).strip,
    "bmG0+2KykgkLeWsXsl6CFbyo4Yc="
  end

  def test_ar_should_initialize_with_proper_params
    assert Sepa::ApplicationRequest.new(@params)
  end

  def test_should_get_key_error_if_private_key_missing
    @params.delete(:private_key)

    assert_raises(KeyError) do
      Sepa::ApplicationRequest.new(@params)
    end
  end

  def test_should_get_key_error_if_cert_missing
    @params.delete(:cert)

    assert_raises(KeyError) do
      Sepa::ApplicationRequest.new(@params)
    end
  end

  def test_should_get_key_error_if_command_missing
    @params.delete(:command)

    assert_raises(KeyError) do
      Sepa::ApplicationRequest.new(@params)
    end
  end

  def test_should_get_key_error_if_customer_id_missing
    @params.delete(:customer_id)

    assert_raises(KeyError) do
      Sepa::ApplicationRequest.new(@params)
    end
  end

  def test_should_get_key_error_if_environment_missing
    @params.delete(:environment)

    assert_raises(KeyError) do
      Sepa::ApplicationRequest.new(@params)
    end
  end

  def test_should_have_customer_id_set_in_with_all_commands
    assert_equal @doc_file.at_css("CustomerId").content, @params[:customer_id]
    assert_equal @doc_get.at_css("CustomerId").content, @params[:customer_id]
    assert_equal @doc_list.at_css("CustomerId").content, @params[:customer_id]
    assert_equal @doc_up.at_css("CustomerId").content, @params[:customer_id]
  end

  def test_should_have_timestamp_set_properly_with_all_commands
    timestamp_file = Time.strptime(@doc_file.at_css("Timestamp").content,
    '%Y-%m-%dT%H:%M:%S%z')

    timestamp_get = Time.strptime(@doc_get.at_css("Timestamp").content,
    '%Y-%m-%dT%H:%M:%S%z')

    timestamp_list = Time.strptime(@doc_list.at_css("Timestamp").content,
    '%Y-%m-%dT%H:%M:%S%z')

    timestamp_up = Time.strptime(@doc_up.at_css("Timestamp").content,
    '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp_file <= Time.now && timestamp_file > (Time.now - 60),
    "Timestamp was not set correctly"

    assert timestamp_get <= Time.now && timestamp_get > (Time.now - 60),
    "Timestamp was not set correctly"

    assert timestamp_list <= Time.now && timestamp_list > (Time.now - 60),
    "Timestamp was not set correctly"

    assert timestamp_up <= Time.now && timestamp_up > (Time.now - 60),
    "Timestamp was not set correctly"
  end

  def test_should_have_command_set_when_get_user_info

    assert_equal @doc_get.at_css("Command").content, "GetUserInfo"
  end

  def test_should_have_command_set_when_download_file_list
    assert_equal @doc_list.at_css("Command").content, "DownloadFileList"
  end

  def test_should_have_command_set_when_download_file
    assert_equal @doc_file.at_css("Command").content, "DownloadFile"
  end

  def test_should_have_command_set_when_upload_file
    assert_equal @doc_up.at_css("Command").content, "UploadFile"
  end

  def test_should_have_environment_set_with_all_commands
    assert_equal @doc_file.at_css("Environment").content, @params[:environment]
    assert_equal @doc_get.at_css("Environment").content, @params[:environment]
    assert_equal @doc_list.at_css("Environment").content, @params[:environment]
    assert_equal @doc_up.at_css("Environment").content, @params[:environment]
  end

  def test_should_have_software_id_set_with_all_commands
    assert_equal @doc_file.at_css("SoftwareId").content,
    "Sepa Transfer Library version " + Sepa::VERSION

    assert_equal @doc_get.at_css("SoftwareId").content,
    "Sepa Transfer Library version " + Sepa::VERSION

    assert_equal @doc_list.at_css("SoftwareId").content,
    "Sepa Transfer Library version " + Sepa::VERSION

    assert_equal @doc_up.at_css("SoftwareId").content,
    "Sepa Transfer Library version " + Sepa::VERSION
  end

  def test_should_have_status_set_when_download_file_list
    assert_equal @doc_list.at_css("Status").content, @params[:status]
  end

  def test_should_have_status_set_when_download_file
    assert_equal @doc_file.at_css("Status").content, @params[:status]
  end

  def test_should_not_have_status_set_when_get_user_info
    refute @doc_get.at_css("Status")
  end

  def test_should_not_have_status_set_when_upload_file
    refute @doc_up.at_css("Status")
  end

  def test_should_have_target_id_set_when_download_file_list
    assert_equal @doc_list.at_css("TargetId").content, @params[:target_id]
  end

  def test_should_have_target_id_set_when_download_file
    assert_equal @doc_file.at_css("TargetId").content, @params[:target_id]
  end

  def test_should_not_have_target_id_set_when_get_user_info
    refute @doc_get.at_css("TargetId")
  end

  def test_should_have_file_type_set_when_download_file_list
    assert_equal @doc_list.at_css("FileType").content, @params[:file_type]
  end

  def test_should_have_file_type_set_when_download_file
    assert_equal @doc_file.at_css("FileType").content, @params[:file_type]
  end

  def test_should_have_file_type_set_when_upload_file
    assert_equal @doc_up.at_css("FileType").content, @params[:file_type]
  end

  def test_should_not_have_file_type_set_when_get_user_info
    refute @doc_get.at_css("FileType")
  end

  def test_should_have_file_reference_set_when_download_file
    assert_equal @doc_file.at_css("FileReference").content,
    @params[:file_reference]
  end

  def test_should_not_have_file_ref_when_download_file_list
    refute @doc_list.at_css("FileReference")
  end

  def test_should_not_have_file_ref_when_get_user_info
    refute @doc_get.at_css("FileReference")
  end

  def test_should_not_have_file_ref_when_upload_file
    refute @doc_up.at_css("FileReference")
  end

  def test_should_have_content_when_upload_file
    assert_equal @doc_up.at_css("Content").content,
    Base64.encode64(@params[:content])
  end

  def test_should_not_have_content_when_download_file_list
    refute @doc_list.at_css("Content")
  end

  def test_should_not_have_content_when_download_file
    refute @doc_file.at_css("Content")
  end

  def test_should_not_have_content_when_get_user_info
    refute @doc_get.at_css("Content")
  end

  def test_should_raise_argument_error_with_invalid_command
    assert_raises(ArgumentError) do
      @params[:command] = :wrong_kind_of_command
      ar = Sepa::ApplicationRequest.new(@params)
      doc = ar.get_as_base64
    end
  end

  def test_digest_is_calculatd_correctly
    calculated_digest = @doc_file.xpath(
    ".//dsig:DigestValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
    ).first.content

    # Remove signature for calculating digest
    @doc_file.xpath(
    "//dsig:Signature", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
    ).remove

    # Calculate digest
    sha1 = OpenSSL::Digest::SHA1.new
    actual_digest = Base64.encode64(sha1.digest(@doc_file.canonicalize))

    # And then make sure the two are equal
    assert_equal calculated_digest.strip, actual_digest.strip
  end

  def test_signature_is_constructed_correctly
    private_key = @params.fetch(:private_key)

    signed_info_node = @doc_file.xpath(
    ".//dsig:SignedInfo", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first

    # The value of the signature node in the constructed ar
    calculated_signature = @doc_file.xpath(
    ".//dsig:SignatureValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#')
    .first.content

    # Calculate the actual signature
    sha1 = OpenSSL::Digest::SHA1.new
    actual_signature = Base64.encode64(private_key.sign(
    sha1, signed_info_node.canonicalize))
    .gsub(/\s+/, "")

    # And then of course assert the two are equal
    assert_equal calculated_signature, actual_signature
  end

  def test_certificate_is_added_correctly
    added_cert = @doc_file
    .xpath(
    ".//dsig:X509Certificate", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#')
    .first.content

    actual_cert = @params.fetch(:cert).to_s
    .split('-----BEGIN CERTIFICATE-----')[1]
    .split('-----END CERTIFICATE-----')[0]
    .gsub(/\s+/, "")

    assert_equal added_cert, actual_cert
  end

  def test_should_validate_against_schema
    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('application_request.xsd'))
      assert xsd.valid?(@doc_file)
    end
  end
end
