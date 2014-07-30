require 'test_helper'

class NordeaApplicationRequestTest < ActiveSupport::TestCase
  def setup
    @nordea_generic_params = nordea_generic_params

    # Convert the keys here since the conversion is usually done by the client and these tests
    # bypass the client
    @nordea_generic_params[:signing_private_key] = rsa_key @nordea_generic_params[:signing_private_key]
    @nordea_generic_params[:signing_certificate] = OpenSSL::X509::Certificate.new @nordea_generic_params[:signing_certificate]

    ar_file = Sepa::SoapBuilder.new(@nordea_generic_params).application_request

    @nordea_generic_params[:command] = :get_user_info
    ar_get = Sepa::SoapBuilder.new(@nordea_generic_params).application_request

    @nordea_generic_params[:command] = :download_file_list
    ar_list = Sepa::SoapBuilder.new(@nordea_generic_params).application_request

    @nordea_generic_params[:command] = :upload_file
    ar_up = Sepa::SoapBuilder.new(@nordea_generic_params).application_request

    @doc_file = Nokogiri::XML(ar_file.to_xml)
    @doc_get = Nokogiri::XML(ar_get.to_xml)
    @doc_list = Nokogiri::XML(ar_list.to_xml)
    @doc_up = Nokogiri::XML(ar_up.to_xml)
  end

  def test_schemas_are_unmodified
    sha1 = OpenSSL::Digest::SHA1.new

    ar_schema = File.read("#{SCHEMA_PATH}/application_request.xsd")
    xmldsig_schema = File.read("#{SCHEMA_PATH}/xmldsig-core-schema.xsd")
    ar_schema_digest = sha1.digest(ar_schema)

    sha1.reset

    xmldsig_schema_digest = sha1.digest(xmldsig_schema)
    assert_equal encode(ar_schema_digest).strip, "1O24A7+/6S7CFYVlhH1jEZh1ARs="
    assert_equal encode(xmldsig_schema_digest).strip, "bmG0+2KykgkLeWsXsl6CFbyo4Yc="
  end

  def test_ar_should_initialize_with_proper_params
    assert Sepa::SoapBuilder.new(@nordea_generic_params)
  end

  def test_should_get_key_error_if_command_missing
    @nordea_generic_params.delete(:command)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@nordea_generic_params)
    end
  end

  def test_should_have_customer_id_set_in_with_all_commands
    assert_equal @doc_file.at_css("CustomerId").content, @nordea_generic_params[:customer_id]
    assert_equal @doc_get.at_css("CustomerId").content, @nordea_generic_params[:customer_id]
    assert_equal @doc_list.at_css("CustomerId").content, @nordea_generic_params[:customer_id]
    assert_equal @doc_up.at_css("CustomerId").content, @nordea_generic_params[:customer_id]
  end

  def test_should_have_timestamp_set_properly_with_all_commands
    timestamp_file = Time.strptime(@doc_file.at_css("Timestamp").content, '%Y-%m-%dT%H:%M:%S%z')
    timestamp_get = Time.strptime(@doc_get.at_css("Timestamp").content, '%Y-%m-%dT%H:%M:%S%z')
    timestamp_list = Time.strptime(@doc_list.at_css("Timestamp").content, '%Y-%m-%dT%H:%M:%S%z')
    timestamp_up = Time.strptime(@doc_up.at_css("Timestamp").content, '%Y-%m-%dT%H:%M:%S%z')

    ts_error = "Timestamp was not set correctly"
    assert timestamp_file <= Time.now && timestamp_file > (Time.now - 60), ts_error
    assert timestamp_get <= Time.now && timestamp_get > (Time.now - 60), ts_error
    assert timestamp_list <= Time.now && timestamp_list > (Time.now - 60), ts_error
    assert timestamp_up <= Time.now && timestamp_up > (Time.now - 60), ts_error
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
    expected_environment = @nordea_generic_params[:environment].upcase

    assert_equal @doc_file.at_css("Environment").content, expected_environment
    assert_equal @doc_get.at_css("Environment").content, expected_environment
    assert_equal @doc_list.at_css("Environment").content, expected_environment
    assert_equal @doc_up.at_css("Environment").content, expected_environment
  end

  def test_should_have_software_id_set_with_all_commands
    string = "Sepa Transfer Library version #{Sepa::VERSION}"

    assert_equal @doc_file.at_css("SoftwareId").content, string
    assert_equal @doc_get.at_css("SoftwareId").content, string
    assert_equal @doc_list.at_css("SoftwareId").content, string
    assert_equal @doc_up.at_css("SoftwareId").content, string
  end

  def test_should_have_status_set_when_download_file_list
    assert_equal @doc_list.at_css("Status").content, @nordea_generic_params[:status]
  end

  def test_should_have_status_set_when_download_file
    assert_equal @doc_file.at_css("Status").content, @nordea_generic_params[:status]
  end

  def test_should_not_have_status_set_when_get_user_info
    refute @doc_get.at_css("Status")
  end

  def test_should_not_have_status_set_when_upload_file
    refute @doc_up.at_css("Status")
  end

  def test_should_have_target_id_set_when_download_file_list
    assert_equal @doc_list.at_css("TargetId").content, @nordea_generic_params[:target_id]
  end

  def test_should_not_have_target_id_set_when_get_user_info
    refute @doc_get.at_css("TargetId")
  end

  def test_should_have_file_type_set_when_download_file_list
    assert_equal @doc_list.at_css("FileType").content, @nordea_generic_params[:file_type]
  end

  def test_should_have_file_type_set_when_download_file
    assert_equal @doc_file.at_css("FileType").content, @nordea_generic_params[:file_type]
  end

  def test_should_have_file_type_set_when_upload_file
    assert_equal @doc_up.at_css("FileType").content, @nordea_generic_params[:file_type]
  end

  def test_should_not_have_file_type_set_when_get_user_info
    refute @doc_get.at_css("FileType")
  end

  def test_should_have_file_reference_set_when_download_file
    assert_equal @doc_file.at_css("FileReference").content, @nordea_generic_params[:file_reference]
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
    assert_equal @doc_up.at_css("Content").content, encode(@nordea_generic_params[:content])
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
      @nordea_generic_params[:command] = :wrong_kind_of_command
      ar = Sepa::ApplicationRequest.new(@nordea_generic_params)
      doc = ar.get_as_base64
    end
  end

  def test_digest_is_calculatd_correctly
    calculated_digest = @doc_file.at_css(
      "dsig|DigestValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
    ).content

    # Remove signature for calculating digest
    @doc_file.at_css(
      "dsig|Signature", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
    ).remove

    # Calculate digest
    sha1 = OpenSSL::Digest::SHA1.new
    actual_digest = encode(sha1.digest(@doc_file.canonicalize))

    # And then make sure the two are equal
    assert_equal calculated_digest.strip, actual_digest.strip
  end

  def test_signature_is_constructed_correctly
    #private_key = @params.fetch(:private_key)

    signed_info_node = @doc_file.at_css(
    "dsig|SignedInfo", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#')

    # The value of the signature node in the constructed ar
    calculated_signature = @doc_file.at_css(
      "dsig|SignatureValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
    ).content

    # Calculate the actual signature
    keys_path = File.expand_path('../keys', __FILE__)
    private_key = rsa_key(File.read("#{keys_path}/nordea.key"))

    sha1 = OpenSSL::Digest::SHA1.new
    actual_signature = encode(private_key.sign(
    sha1, signed_info_node.canonicalize))

    # And then of course assert the two are equal
    assert_equal calculated_signature, actual_signature
  end

  def test_certificate_is_added_correctly
    added_certificate = @doc_file.at_css(
      "dsig|X509Certificate", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
    ).content

    actual_certificate = @nordea_generic_params.fetch(:signing_certificate).to_s
    actual_certificate = actual_certificate.split('-----BEGIN CERTIFICATE-----')[1]
    actual_certificate = actual_certificate.split('-----END CERTIFICATE-----')[0]
    actual_certificate.gsub!(/\s+/, "")

    assert_equal added_certificate, actual_certificate
  end

  def test_should_validate_against_schema
    Dir.chdir(SCHEMA_PATH) do
      xsd = Nokogiri::XML::Schema(IO.read('application_request.xsd'))
      assert xsd.valid?(@doc_file)
    end
  end

end
