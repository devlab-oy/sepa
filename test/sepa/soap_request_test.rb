require File.expand_path('../../test_helper.rb', __FILE__)

class SoapRequestTest < MiniTest::Unit::TestCase
  def setup
    keys_path = File.expand_path('../nordea_test_keys', __FILE__)

    private_key = OpenSSL::PKey::RSA.new(File.read("#{keys_path}/nordea.key"))
    cert = OpenSSL::X509::Certificate.new(File.read("#{keys_path}/nordea.crt"))

    @params = {
      private_key: private_key,
      cert: cert,
      command: :get_user_info,
      customer_id: '11111111',
      environment: 'PRODUCTION',
      status: 'NEW',
      target_id: '11111111A1',
      language: 'FI',
      file_type: 'TITO',
      wsdl: 'sepa/wsdl/wsdl_nordea.xml',
      content: Base64.encode64("Kurppa"),
      file_reference: "11111111A12006030329501800000014"
    }

    @soap_request = Sepa::SoapRequest.new(@params)

    @doc = Nokogiri::XML(@soap_request.to_xml)
  end

  def test_should_initialize_with_proper_params
    assert Sepa::SoapRequest.new(@params)
  end

  def test_should_get_error_if_private_key_missing
    @params.delete(:private_key)
    assert_raises(KeyError) do
      Sepa::SoapRequest.new(@params)
    end
  end

  def test_should_get_error_if_cert_missing
    @params.delete(:cert)
    assert_raises(KeyError) do
      Sepa::SoapRequest.new(@params)
    end
  end

  def test_should_get_error_if_command_missing
    @params.delete(:command)
    assert_raises(KeyError) do
      Sepa::SoapRequest.new(@params)
    end
  end

  def test_should_get_error_if_customer_id_missing
    @params.delete(:customer_id)
    assert_raises(KeyError) do
      Sepa::SoapRequest.new(@params)
    end
  end

  def test_sender_id_is_properly_set
    assert_equal @params[:customer_id],
    @doc.xpath("//bxd:SenderId", 'bxd' => 'http://model.bxd.fi').first.content
  end

  # Just testing that the content of the node is an actual hex number and that
  # the length is 30 characters because 35 is the max that can be set
  # according to the schema and Securerandom can generate only some int times 2
  def test_request_id_is_properly_set
    request_id_node =
    @doc.xpath("//bxd:RequestId", 'bxd' => 'http://model.bxd.fi').first

    assert request_id_node.content =~ /^[0-9A-F]+$/i
    assert_equal request_id_node.content.length, 34
  end

  def test_timestamp_is_set_correctly
    timestamp_node =
    @doc.xpath("//bxd:Timestamp", 'bxd' => 'http://model.bxd.fi').first

    timestamp = Time.strptime(timestamp_node.content, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= Time.now && timestamp > (Time.now - 60)
  end

  def test_language_is_set_correctly
    language_node =
    @doc.xpath("//bxd:Language", 'bxd' => 'http://model.bxd.fi').first

    assert_equal language_node.content, @params[:language]
  end

  def test_user_agent_is_set_correctly
    user_agent_node =
    @doc.xpath("//bxd:UserAgent", 'bxd' => 'http://model.bxd.fi').first

    assert_equal user_agent_node.content,
    "Sepa Transfer Library version " + Sepa::VERSION
  end

  # I'm quite sure that receiver id and target is are the same
  def test_receiver_is_is_set_correctly
    receiver_id_node =
    @doc.xpath("//bxd:ReceiverId", 'bxd' => 'http://model.bxd.fi').first

    assert_equal receiver_id_node.content, @params[:target_id]
  end

  # Just test that the content of application request is a base64 encoded xml
  # document and that it's customer is matches the one provided in the params
  def test_application_request_should_be_inserted_properly
    ar_node =
    @doc.xpath("//bxd:ApplicationRequest", 'bxd' => 'http://model.bxd.fi').first

    ar_doc = Nokogiri::XML(Base64.decode64(ar_node.content))

    assert ar_doc.respond_to?(:canonicalize)
    assert_equal ar_doc.at_css("CustomerId").content, @params[:customer_id]
  end

  def test_cert_is_added_correctly
    added_cert =
    @doc.xpath("//wsse:BinarySecurityToken", 'wsse' => 'http://docs.oasis-' +
    'open.org/wss/2004/01/oasis-200401-wss-wssecurity-' +
    'secext-1.0.xsd').first.content

    actual_cert = @params.fetch(:cert).to_s
    actual_cert = actual_cert.split('-----BEGIN CERTIFICATE-----')[1]
    actual_cert = actual_cert.split('-----END CERTIFICATE-----')[0]
    actual_cert = actual_cert.gsub(/\s+/, "")

    assert_equal added_cert, actual_cert
  end

  def test_body_digest_is_calculated_correctly
    sha1 = OpenSSL::Digest::SHA1.new

    # Digest which is calculated from the body and added to the header
    added_digest = @doc.xpath("//dsig:Reference[@URI='#sdf6sa7d86f87s6df786" +
    "sd87f6s8fsda']/dsig:DigestValue", 'dsig' => 'http://www.w3.org' +
    '/2000/09/xmldsig#').first.content

    body_node = @doc.xpath("//env:Body", 'env' =>
    'http://schemas.xmlsoap.org/soap/envelope/').first

    body_node = body_node.canonicalize(
    mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,
    with_comments=false)

    actual_digest = Base64.encode64(sha1.digest(body_node)).strip

    assert_equal actual_digest, added_digest
  end
end