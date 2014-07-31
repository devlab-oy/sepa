require 'test_helper'

class DanskeCertSoapBuilderTest < ActiveSupport::TestCase
  def setup
    @danske_create_certificate_params = danske_create_certificate_params

    @cert_request = Sepa::SoapBuilder.new(@danske_create_certificate_params)
    @enc_private_key = rsa_key File.read("#{DANSKE_TEST_KEYS_PATH}/enc_private_key.pem")
    @doc = Nokogiri::XML(@cert_request.to_xml)

    # Namespaces
    @pkif = 'http://danskebank.dk/PKI/PKIFactoryService'
    @dsig = 'http://www.w3.org/2000/09/xmldsig#'
  end

  def test_should_raise_error_if_command_missing
    @danske_create_certificate_params.delete(:command)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@danske_create_certificate_params)
    end
  end

  def test_sender_id_is_properly_set
    sender_id = @doc.at("SenderId", "xmlns" => @pkif).content
    assert_equal sender_id, @danske_create_certificate_params[:customer_id]
  end

  def test_customer_id_is_properly_set
    customer_id = @doc.at("CustomerId", "xmlns" => @pkif).content
    assert_equal customer_id, @danske_create_certificate_params[:customer_id]
  end

  def test_request_id_is_properly_set
    request_id = @doc.at("RequestId", 'xmlns' => @pkif).content

    assert request_id =~ /^[0-9A-F]+$/i
    assert_equal request_id.length, 10
  end

  def test_timestamp_is_set_correctly
    timestamp_node = @doc.at(
      "Timestamp", 'xmlns' => @pkif
    )
    timestamp = Time.strptime(timestamp_node.content, '%Y-%m-%dT%H:%M:%S%z')

    assert timestamp <= Time.now && timestamp > (Time.now - 60)
  end

  def test_interface_version_is_properly_set
    interface_version = @doc.at("InterfaceVersion", 'xmlns' => @pkif).content
    assert_equal interface_version, '1'
  end

  def test_certificate_is_added_properly
    embedded_certificate = @doc.at("X509Certificate", 'xmlns' => @dsig).content.gsub(/\s+/, "")

    actual_certificate = @danske_create_certificate_params[:encryption_certificate]
    actual_certificate = actual_certificate.split('-----BEGIN CERTIFICATE-----')[1]
    actual_certificate = actual_certificate.split('-----END CERTIFICATE-----')[0]
    actual_certificate.gsub!(/\s+/, "")

    assert_equal embedded_certificate, actual_certificate
  end

  def test_encrypted_key_is_added_properly_and_can_be_decrypted
    enc_key = @doc.css("CipherValue", 'xmlns' => XMLENC)[0].content
    enc_key = decode enc_key
    assert @enc_private_key.private_decrypt(enc_key)
  end

  def test_encypted_data_is_added_properly_and_can_be_decrypted
    enc_key = @doc.css("CipherValue", 'xmlns' => XMLENC)[0].content
    enc_key = decode enc_key
    key = @enc_private_key.private_decrypt(enc_key)

    encypted_data = @doc.css("CipherValue", 'xmlns' => XMLENC)[1].content
    encypted_data = decode encypted_data
    iv = encypted_data[0, 8]
    encypted_data = encypted_data[8, encypted_data.length]

    decipher = OpenSSL::Cipher.new('DES-EDE3-CBC')
    decipher.decrypt
    decipher.key = key
    decipher.iv = iv

    decrypted_data = decipher.update(encypted_data) + decipher.final

    assert_respond_to(Nokogiri::XML(decrypted_data), :css)
  end

  def test_should_validate_against_schema
    Dir.chdir(SCHEMA_PATH) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(@doc)
    end
  end

end
