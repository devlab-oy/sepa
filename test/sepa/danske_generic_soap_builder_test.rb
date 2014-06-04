require File.expand_path('../../test_helper.rb', __FILE__)

class DanskeGenericSoapBuilderTest < ActiveSupport::TestCase
  def setup
    @schemas_path = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)

    keys_path = File.expand_path('../danske_test_keys', __FILE__)

    private_key_path = "#{keys_path}/signing_private_key.pem"
    private_key = File.read private_key_path

    signing_cert_path = "#{keys_path}/own_signing_cert.pem"
    signing_cert = File.read signing_cert_path

    enc_cert_path = "#{keys_path}/bank_encryption_cert.pem"
    enc_cert = File.read enc_cert_path

    @params = {
      bank: :danske,
      private_key: OpenSSL::PKey::RSA.new(private_key),
      command: :upload_file,
      customer_id: '360817',
      environment: 'TEST',
      enc_cert: enc_cert,
      cert: signing_cert,
      language: 'EN',
      status: 'ALL',
      target_id: 'Danske FI',
      file_type: 'pain.001.001.02',
      content: Base64.encode64('kissa'),
      file_reference: "11111111A12006030329501800000014"
    }

    @soap_request = Sepa::SoapBuilder.new(@params)

    @doc = Nokogiri::XML(@soap_request.to_xml)

    # Namespaces
    @bxd = 'http://model.bxd.fi'
  end

  def test_should_initialize_request_with_proper_params
    assert Sepa::SoapBuilder.new(@params).to_xml
  end

  def test_should_get_error_if_command_missing
    @params.delete(:command)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params)
    end
  end

  def test_should_load_correct_template_with_download_file_list
    @params[:command] = :download_file_list
    doc = Nokogiri::XML(Sepa::SoapBuilder.new(@params).to_xml)

    assert doc.at('//cor:downloadFileListin', 'cor' => 'http://bxd.fi/' \
                  'CorporateFileService')
  end

  def test_should_load_correct_template_with_get_user_info
    @params[:command] = :get_user_info
    doc = Nokogiri::XML(Sepa::SoapBuilder.new(@params).to_xml)

    assert doc.at('//cor:getUserInfoin', 'cor' => 'http://bxd.fi/' \
                  'CorporateFileService')
  end

  def test_should_load_correct_template_with_download_file
    @params[:command] = :download_file
    doc = Nokogiri::XML(Sepa::SoapBuilder.new(@params).to_xml)

    assert doc.at('//cor:downloadFilein', 'cor' => 'http://bxd.fi/' \
                  'CorporateFileService')
  end

  def test_should_load_correct_template_with_upload_file
    @params[:command] = :upload_file
    doc = Nokogiri::XML(Sepa::SoapBuilder.new(@params).to_xml)

    assert doc.at('//cor:uploadFilein', 'cor' => 'http://bxd.fi/' \
                  'CorporateFileService')
  end

  def test_should_raise_error_if_unrecognised_command
    @params[:command] = :wrong_command

    assert_raises(ArgumentError) do
      soap = Sepa::SoapBuilder.new(@params)
    end
  end

  def test_sender_id_is_properly_set
    assert_equal @params[:customer_id],
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

    assert_equal language_node.content, @params[:language]
  end

  def test_user_agent_is_set_correctly
    user_agent_node = @doc.at("//bxd:UserAgent", 'bxd' => 'http://model.bxd.fi')

    assert_equal user_agent_node.content,
      "Sepa Transfer Library version " + Sepa::VERSION
  end

  def test_receiver_is_is_set_correctly
    receiver_id_node = @doc.at("//bxd:ReceiverId", 'bxd' => 'http://' \
                               'model.bxd.fi')

    assert_equal receiver_id_node.content, @params[:target_id]
  end

  def test_cert_is_added_correctly
    added_cert = @doc.at(
      "//wsse:BinarySecurityToken", 'wsse' => 'http://docs.oasis-open.org/wss' \
      '/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'
    ).content

    actual_cert = OpenSSL::X509::Certificate.new(
      @params.fetch(:cert)
    ).to_s

    actual_cert = actual_cert.split('-----BEGIN CERTIFICATE-----')[1]
    actual_cert = actual_cert.split('-----END CERTIFICATE-----')[0]
    actual_cert = actual_cert.gsub(/\s+/, "")

    assert_equal added_cert, actual_cert
  end

  def test_body_digest_is_calculated_correctly
    sha1 = OpenSSL::Digest::SHA1.new

    # Digest which is calculated from the body and added to the header
    added_digest = @doc.at(
      "//dsig:Reference[@URI='#sdf6sa7d86f87s6df786sd87f6s8fsda']/dsig:Digest" \
      "Value", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
    ).content

    body_node = @doc.at(
      "//env:Body", 'env' => 'http://schemas.xmlsoap.org/soap/envelope/'
    )

    body_node = body_node.canonicalize(
      mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,
      with_comments=false
    )

    actual_digest = Base64.encode64(sha1.digest(body_node)).strip

    assert_equal actual_digest, added_digest
  end

  def test_header_created_timestamp_is_added_correctly
    timestamp_node = @doc.at(
      "//wsu:Created", 'wsu' => 'http://docs.oasis-open.org/wss/2004/01/oasis' \
      '-200401-wss-wssecurity-utility-1.0.xsd'
    )

    timestamp = Time.strptime(timestamp_node.content, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= Time.now && timestamp > (Time.now - 60)
  end

  def test_header_expires_timestamp_is_added_correctly
    timestamp_node = @doc.at(
      "//wsu:Expires", 'wsu' => 'http://docs.oasis-open.org/wss/2004/01/oasis' \
      '-200401-wss-wssecurity-utility-1.0.xsd'
    )

    timestamp = Time.strptime(timestamp_node.content, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= (Time.now + 300) &&
      timestamp > ((Time.now + 300) - 60)
  end

  def test_header_timestamps_digest_is_calculated_correctly
    sha1 = OpenSSL::Digest::SHA1.new

    added_digest = @doc.at(
      "//dsig:Reference[@URI='#dsfg8sdg87dsf678g6dsg6ds7fg']/dsig:DigestValue",
      'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
    ).content

    timestamp_node = @doc.at(
      "//wsu:Timestamp", 'wsu' => 'http://docs.oasis-open.org/wss/2004/01/oas' \
      'is-200401-wss-wssecurity-utility-1.0.xsd'
    )

    timestamp_node = timestamp_node.canonicalize(
      mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,
      with_comments=false
    )

    actual_digest = Base64.encode64(sha1.digest(timestamp_node)).strip

    assert_equal actual_digest, added_digest
  end

  def test_signature_is_calculated_correctly
    sha1 = OpenSSL::Digest::SHA1.new

    private_key = OpenSSL::PKey::RSA.new(@params.fetch(:private_key))

    added_signature = @doc.at("//dsig:SignatureValue", 'dsig' => 'http://' \
                              'www.w3.org/2000/09/xmldsig#').content

    signed_info_node = @doc.at("//dsig:SignedInfo", 'dsig' => 'http://' \
                               'www.w3.org/2000/09/xmldsig#')

    signed_info_node = signed_info_node.canonicalize(
      mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,
      with_comments=false
    )

    actual_signature = Base64.encode64(
      private_key.sign(sha1, signed_info_node)
    ).gsub(/\s+/, "")

    assert_equal actual_signature, added_signature
  end

  def test_should_validate_against_schema
    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(@doc)
    end
  end

  def test_schema_validation_should_fail_with_wrong_must_understand_value
    security_node = @doc.at(
      '//wsse:Security', 'wsse' => 'http://docs.oasis-open.org/wss/2004/01/' \
      'oasis-200401-wss-wssecurity-secext-1.0.xsd'
    )

    security_node['env:mustUnderstand'] = '3'

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      refute xsd.valid?(@doc)
    end
  end

  def test_should_validate_against_ws_security_schema
    ws_node = @doc.xpath(
      '//wsse:Security', 'wsse' => 'http://docs.oasis-open.org/wss/2004/01/' \
      'oasis-200401-wss-wssecurity-secext-1.0.xsd'
    )

    ws_node = ws_node.to_xml

    ws_node = Nokogiri::XML(ws_node)

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema IO.read 'oasis-200401-wss-wssecurity-' \
        'secext-1.0.xsd'
      assert xsd.valid?(ws_node)
    end
  end
end
