require 'test_helper'

class NordeaGenericSoapBuilderTest < ActiveSupport::TestCase

  def setup
    @nordea_generic_params = nordea_generic_params

    # Convert the keys here since the conversion is usually done by the client and these tests
    # bypass the client
    @nordea_generic_params[:signing_private_key] = rsa_key @nordea_generic_params[:signing_private_key]
    @nordea_generic_params[:signing_certificate] = x509_certificate @nordea_generic_params[:signing_certificate]

    @soap_request = Sepa::SoapBuilder.new(@nordea_generic_params)
    @doc = Nokogiri::XML(@soap_request.to_xml)
  end

  def test_should_get_error_if_command_missing
    @nordea_generic_params.delete(:command)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@nordea_generic_params)
    end
  end

  def test_should_load_correct_template_with_download_file_list
    @nordea_generic_params[:command] = :download_file_list
    doc = Nokogiri::XML(Sepa::SoapBuilder.new(@nordea_generic_params).to_xml)

    assert doc.xpath(
      '//cor:downloadFileListin', 'cor' => 'http://bxd.fi/CorporateFileService'
    ).first
  end

  def test_should_load_correct_template_with_get_user_info
    @nordea_generic_params[:command] = :get_user_info
    doc = Nokogiri::XML(Sepa::SoapBuilder.new(@nordea_generic_params).to_xml)

    assert doc.xpath(
      '//cor:getUserInfoin', 'cor' => 'http://bxd.fi/CorporateFileService'
    ).first
  end

  def test_should_load_correct_template_with_download_file
    @nordea_generic_params[:command] = :download_file
    doc = Nokogiri::XML(Sepa::SoapBuilder.new(@nordea_generic_params).to_xml)

    assert doc.xpath(
      '//cor:downloadFilein', 'cor' => 'http://bxd.fi/CorporateFileService'
    ).first
  end

  def test_should_load_correct_template_with_upload_file
    @nordea_generic_params[:command] = :upload_file
    doc = Nokogiri::XML(Sepa::SoapBuilder.new(@nordea_generic_params).to_xml)

    assert doc.xpath(
      '//cor:uploadFilein', 'cor' => 'http://bxd.fi/CorporateFileService'
    ).first
  end

  def test_should_raise_error_if_unrecognised_command
    @nordea_generic_params[:command] = :wrong_command

    assert_raises(ArgumentError) do
      soap = Sepa::SoapBuilder.new(@nordea_generic_params)
    end
  end

  def test_sender_id_is_properly_set
    assert_equal @nordea_generic_params[:customer_id],
      @doc.xpath("//bxd:SenderId", 'bxd' => 'http://model.bxd.fi').first.content
  end

  # Just testing that the content of the node is an actual hex number and that
  # the length is 30 characters because 35 is the max that can be set
  # according to the schema and Securerandom can generate only some int times 2
  def test_request_id_is_properly_set
    request_id_node = @doc.xpath(
      "//bxd:RequestId", 'bxd' => 'http://model.bxd.fi'
    ).first

    assert request_id_node.content =~ /^[0-9A-F]+$/i
    assert_equal request_id_node.content.length, 34
  end

  def test_timestamp_is_set_correctly
    timestamp_node = @doc.xpath(
      "//bxd:Timestamp", 'bxd' => 'http://model.bxd.fi'
    ).first

    timestamp = Time.strptime(timestamp_node.content, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= Time.now && timestamp > (Time.now - 60)
  end

  def test_language_is_set_correctly
    language_node = @doc.xpath(
      "//bxd:Language", 'bxd' => 'http://model.bxd.fi'
    ).first

    assert_equal language_node.content, @nordea_generic_params[:language]
  end

  def test_user_agent_is_set_correctly
    user_agent_node = @doc.xpath(
      "//bxd:UserAgent", 'bxd' => 'http://model.bxd.fi'
    ).first

    assert_equal user_agent_node.content, "Sepa Transfer Library version " + Sepa::VERSION
  end

  def test_receiver_is_is_set_correctly
    receiver_id_node = @doc.xpath(
      "//bxd:ReceiverId", 'bxd' => 'http://model.bxd.fi'
    ).first

    assert_equal receiver_id_node.content, @nordea_generic_params[:target_id]
  end

  # Just test that the content of application request is a base64 encoded xml
  # document and that it's customer is matches the one provided in the params
  def test_application_request_should_be_inserted_properly
    ar_node = @doc.xpath(
      "//bxd:ApplicationRequest", 'bxd' => 'http://model.bxd.fi'
    ).first

    ar_doc = Nokogiri::XML(decode(ar_node.content))

    assert ar_doc.respond_to?(:canonicalize)
    assert_equal ar_doc.at_css("CustomerId").content, @nordea_generic_params[:customer_id]
  end

  def test_cert_is_added_correctly
    wsse = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'

    added_certificate = @doc.xpath(
      "//wsse:BinarySecurityToken", 'wsse' => wsse
    ).first.content

    actual_certificate = @nordea_generic_params.fetch(:signing_certificate).to_s
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

    body_node = @doc.xpath(
      "//env:Body", 'env' => 'http://schemas.xmlsoap.org/soap/envelope/'
    ).first

    body_node = body_node.canonicalize(
      mode = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0, inclusive_namespaces = nil,
      with_comments = false
    )

    actual_digest = encode(sha1.digest(body_node)).strip

    assert_equal actual_digest, added_digest
  end

  def test_header_created_timestamp_is_added_correctly
    wsu = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'

    timestamp_node = @doc.xpath(
      "//wsu:Created", 'wsu' => wsu
    ).first

    timestamp = Time.strptime(timestamp_node.content, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= Time.now && timestamp > (Time.now - 60)
  end

  def test_header_expires_timestamp_is_added_correctly
    wsu = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'

    timestamp_node = @doc.xpath(
      "//wsu:Expires", 'wsu' => wsu
    ).first

    timestamp = Time.strptime(timestamp_node.content, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= (Time.now + 300) && timestamp > ((Time.now + 300) - 60)
  end

  def test_header_timestamps_digest_is_calculated_correctly
    sha1 = OpenSSL::Digest::SHA1.new

    reference_node = @doc.css('dsig|Reference')[0]
    added_digest = reference_node.at('dsig|DigestValue').content

    wsu = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'

    timestamp_node = @doc.xpath(
      "//wsu:Timestamp", 'wsu' => wsu
    ).first

    timestamp_node = timestamp_node.canonicalize(
      mode = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0, inclusive_namespaces = nil,
      with_comments = false
    )

    actual_digest = encode(sha1.digest(timestamp_node)).strip

    assert_equal actual_digest, added_digest
  end

  def test_signature_is_calculated_correctly
    sha1 = OpenSSL::Digest::SHA1.new
    signing_private_key = @nordea_generic_params.fetch(:signing_private_key)

    added_signature = @doc.xpath(
      "//dsig:SignatureValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
    ).first.content

    signed_info_node = @doc.xpath(
      "//dsig:SignedInfo", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
    ).first

    signed_info_node = signed_info_node.canonicalize(
      mode = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0, inclusive_namespaces = nil,
      with_comments = false
    )

    actual_signature = encode(
      signing_private_key.sign(sha1, signed_info_node)
    ).gsub(/\s+/, "")

    assert_equal actual_signature, added_signature
  end

  def test_should_validate_against_schema
    Dir.chdir(SCHEMA_PATH) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(@doc)
    end
  end

  def test_schema_validation_should_fail_with_wrong_must_understand_value
    wsse = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'
    security_node = @doc.xpath(
      '//wsse:Security', 'wsse' => wsse
    ).first

    security_node['env:mustUnderstand'] = '3'

    Dir.chdir(SCHEMA_PATH) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      refute xsd.valid?(@doc)
    end
  end

  def test_should_validate_against_ws_security_schema
    wsse = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'

    ws_node = @doc.xpath(
      '//wsse:Security', 'wsse' => wsse
    )

    ws_node = ws_node.to_xml
    ws_node = Nokogiri::XML(ws_node)

    Dir.chdir(SCHEMA_PATH) do
      xsd = Nokogiri::XML::Schema IO.read 'oasis-200401-wss-wssecurity-secext-1.0.xsd'
      assert xsd.valid?(ws_node)
    end
  end

end
