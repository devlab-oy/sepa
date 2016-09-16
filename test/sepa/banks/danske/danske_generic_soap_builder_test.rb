require 'test_helper'

class DanskeGenericSoapBuilderTest < ActiveSupport::TestCase
  def setup
    keys_path = File.expand_path('../keys', __FILE__)

    signing_private_key_path = "#{keys_path}/signing_key.pem"
    signing_private_key = File.read signing_private_key_path

    signing_certificate_path = "#{keys_path}/own_signing_cert.pem"
    signing_certificate = File.read signing_certificate_path

    encryption_certificate_path = "#{keys_path}/own_enc_cert.pem"
    encryption_certificate = File.read encryption_certificate_path

    @danske_generic_params = danske_generic_params

    # Convert keys in danske generic params, because this is usually done by the client
    @danske_generic_params[:signing_private_key] = rsa_key(@danske_generic_params[:signing_private_key])

    @soap_request = Sepa::SoapBuilder.new(@danske_generic_params)

    @doc = Nokogiri::XML(@soap_request.to_xml)

    # Namespaces
    @bxd = 'http://model.bxd.fi'
  end

  def test_should_initialize_request_with_proper_params
    assert Sepa::SoapBuilder.new(@danske_generic_params).to_xml
  end

  def test_should_get_error_if_command_missing
    @danske_generic_params.delete(:command)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@danske_generic_params)
    end
  end

  def test_should_load_correct_template_with_download_file_list
    @danske_generic_params[:command] = :download_file_list
    doc = Nokogiri::XML(Sepa::SoapBuilder.new(@danske_generic_params).to_xml)

    assert doc.at('//cor:downloadFileListin', 'cor' => 'http://bxd.fi/CorporateFileService')
  end

  def test_should_load_correct_template_with_get_user_info
    @danske_generic_params[:command] = :get_user_info
    doc = Nokogiri::XML(Sepa::SoapBuilder.new(@danske_generic_params).to_xml)

    assert doc.at('//cor:getUserInfoin', 'cor' => 'http://bxd.fi/CorporateFileService')
  end

  def test_should_load_correct_template_with_download_file
    @danske_generic_params[:command] = :download_file
    doc = Nokogiri::XML(Sepa::SoapBuilder.new(@danske_generic_params).to_xml)

    assert doc.at('//cor:downloadFilein', 'cor' => 'http://bxd.fi/CorporateFileService')
  end

  def test_should_load_correct_template_with_upload_file
    @danske_generic_params[:command] = :upload_file
    doc = Nokogiri::XML(Sepa::SoapBuilder.new(@danske_generic_params).to_xml)

    assert doc.at('//cor:uploadFilein', 'cor' => 'http://bxd.fi/CorporateFileService')
  end

  def test_should_raise_error_if_unrecognised_command
    @danske_generic_params[:command] = :wrong_command

    assert_raises(ArgumentError) do
      soap = Sepa::SoapBuilder.new(@danske_generic_params)
    end
  end

  def test_sender_id_is_properly_set
    assert_equal @danske_generic_params[:customer_id],
                 @doc.at("//bxd:SenderId", 'bxd' => 'http://model.bxd.fi').content
  end

  def test_request_id_is_properly_set
    request_id = @doc.at("RequestId", 'xmlns' => @bxd).content

    assert request_id =~ /^[0-9A-F]+$/i
    assert_equal request_id.length, 10
  end

  def test_timestamp_is_set_correctly
    timestamp_node = @doc.at("//bxd:Timestamp", 'bxd' => 'http://model.bxd.fi')
    timestamp = Time.strptime(timestamp_node.content, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= Time.now && timestamp > (Time.now - 60)
  end

  def test_language_is_set_correctly
    language_node = @doc.at("//bxd:Language", 'bxd' => 'http://model.bxd.fi')

    assert_equal language_node.content, @danske_generic_params[:language]
  end

  def test_user_agent_is_set_correctly
    user_agent_node = @doc.at("//bxd:UserAgent", 'bxd' => 'http://model.bxd.fi')

    assert_equal user_agent_node.content, "Sepa Transfer Library version " + Sepa::VERSION
  end

  def test_receiver_is_is_set_correctly
    receiver_id_node = @doc.at("//bxd:ReceiverId", 'bxd' => 'http://model.bxd.fi')

    assert_equal 'DABAFIHH', receiver_id_node.content
  end

  def test_cert_is_added_correctly
    wsse = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'

    added_certificate = @doc.at(
      "//wsse:BinarySecurityToken", 'wsse' => wsse
    ).content

    actual_certificate = x509_certificate(
      @danske_generic_params.fetch(:own_signing_certificate)
    ).to_s

    actual_certificate = actual_certificate.split('-----BEGIN CERTIFICATE-----')[1]
    actual_certificate = actual_certificate.split('-----END CERTIFICATE-----')[0]
    actual_certificate = actual_certificate.gsub(/\s+/, "")

    assert_equal added_certificate, actual_certificate
  end

  def test_body_digest_is_calculated_correctly
    sha1 = OpenSSL::Digest::SHA1.new

    # Digest which is calculated from the body and added to the header
    reference_node = @doc.css('dsig|Reference')[1]
    added_digest = reference_node.at('dsig|DigestValue').content

    body_node = @doc.at(
      "//env:Body", 'env' => 'http://schemas.xmlsoap.org/soap/envelope/'
    )

    body_node = body_node.canonicalize(
      mode = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
      inclusive_namespaces = nil, with_comments = false
    )

    actual_digest = encode(sha1.digest(body_node)).strip

    assert_equal actual_digest, added_digest
  end

  def test_header_created_timestamp_is_added_correctly
    wsu = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'

    timestamp_node = @doc.at(
      "//wsu:Created", 'wsu' => wsu
    )

    timestamp = Time.strptime(timestamp_node.content, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= Time.now && timestamp > (Time.now - 60)
  end

  def test_header_expires_timestamp_is_added_correctly
    wsu = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'

    timestamp_node = @doc.at(
      "//wsu:Expires", 'wsu' => wsu
    )

    timestamp = Time.strptime(timestamp_node.content, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= (Time.now + 300) &&
           timestamp > ((Time.now + 300) - 60)
  end

  def test_header_timestamps_digest_is_calculated_correctly
    sha1 = OpenSSL::Digest::SHA1.new

    reference_node = @doc.css('dsig|Reference')[0]
    added_digest = reference_node.at('dsig|DigestValue').content

    wsu = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'

    timestamp_node = @doc.at(
      "//wsu:Timestamp", 'wsu' => wsu
    )

    timestamp_node = timestamp_node.canonicalize(
      mode = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0, inclusive_namespaces = nil,
      with_comments = false
    )

    actual_digest = encode(sha1.digest(timestamp_node)).strip

    assert_equal actual_digest, added_digest
  end

  def test_signature_is_calculated_correctly
    sha1 = OpenSSL::Digest::SHA1.new

    private_key = rsa_key(@danske_generic_params.fetch(:signing_private_key))

    added_signature = @doc.at(
      "//dsig:SignatureValue",
      'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
    ).content

    signed_info_node = @doc.at("//dsig:SignedInfo", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#')

    signed_info_node = signed_info_node.canonicalize(
      mode = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0, inclusive_namespaces = nil,
      with_comments = false
    )

    actual_signature = encode(
      private_key.sign(sha1, signed_info_node)
    ).gsub(/\s+/, "")

    assert_equal actual_signature, added_signature
  end

  def test_should_validate_against_schema
    assert_valid_against_schema 'soap.xsd', @doc
  end

  def test_schema_validation_should_fail_with_wrong_must_understand_value
    wsse          = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'
    security_node = @doc.at('//wsse:Security', 'wsse' => wsse)

    security_node['env:mustUnderstand'] = '3'

    refute_valid_against_schema 'soap.xsd', @doc
  end

  def test_should_validate_against_ws_security_schema
    wsse    = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'
    ws_node = @doc.xpath('//wsse:Security', 'wsse' => wsse)
    ws_node = ws_node.to_xml
    ws_node = Nokogiri::XML(ws_node)

    assert_valid_against_schema 'oasis-200401-wss-wssecurity-secext-1.0.xsd', ws_node
  end

  test 'application request is encrypted' do
    application_request = decode(@doc.at('bxd|ApplicationRequest', bxd: BXD).content)
    application_request = Nokogiri::XML(application_request)

    assert_nil     application_request.at('ApplicationRequest')
    assert_not_nil application_request.at('xenc|EncryptedData')
  end
end
