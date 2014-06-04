require File.expand_path('../../test_helper.rb', __FILE__)

class DanskeCertSoapBuilderTest < ActiveSupport::TestCase
  def setup
    @schemas_path = File.expand_path('../../../lib/sepa/xml_schemas', __FILE__)

    @templates_path = File.expand_path('../../../lib/sepa/xml_templates/soap',
                                       __FILE__)

    keys_path = File.expand_path('../danske_test_keys', __FILE__)

    encryptpkcs = "-----BEGIN CERTIFICATE REQUEST-----
MIICdzCCAV8CAQEwMjEPMA0GA1UEAwwGaGVtdWxpMR8wHQYKCZImiZPyLGQBGRYP
bnV1c2thbXVpa2t1bmVuMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
5aHmVXcfogDqJ3kUfK8ARzdkQ/dm9j4rHbGNh4xmlKCMUwCmmo2LOKMKvviD7qwz
n1lDsPIClbmZaxc3vFlpNj5A6YVg7SpCU/Cx9RtTY+2vWQF29RWw5UktPDALIRNC
boKuNykWqbWhwW80YOO3MXlASw2EF2nfsxLGXNmiB7kKaxPrTsNV9CO4rVIrYJj5
2+1MZSEhEQn9H9VrKgCNlDN/6LCs/TnSC7Np1jOTjo5Nen95afE0KUEbSnMw8Ihw
ymOFF0zgxiCQ1kme5fYXqCZZJOU+zS3pKO/LdnULu6/uJ1D0JWjIwWBqEwTwMqhj
NnsJaoJiJJnQtuFcVIhXEQIDAQABoAAwDQYJKoZIhvcNAQEFBQADggEBAAlVfy+G
GUPYnTfrRoBvgSMz5dR7rynQe5wxHWTtk71xbODSIZNFUntYa4tSAzaIEp65FxTj
WyGlBZcdzCPd39DJtfxeiZ8q4UKx47VCt4jIzOSpM2jvGzlUpHnm2Eh9rQHqMRye
C4T49gWBEqsTvZL+hWE9dAQq4Y+P3h9UWr49bMQNbSxERw3fDzWvcEJsSq+4Ml12
+sPV+Euz5phCzqt15v+6jfqlEgGj27k3MlF+EglX0BWduGw4RxfoOdGQNBwdXPkz
db1f0XsYTW1NUYoL8O8uxzoNcysyBW/VGP01e2LXB8whWn4xtDtaLpyt/v4ow04V
9v3lfL5ZDl1gIEY=
-----END CERTIFICATE REQUEST-----"

    signingpkcs = "-----BEGIN CERTIFICATE REQUEST-----
MIICdzCCAV8CAQEwMjEPMA0GA1UEAwwGaGVtdWxpMR8wHQYKCZImiZPyLGQBGRYP
bnV1c2thbXVpa2t1bmVuMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
y4zgajeMzFrBR4zsJ50qo4fxHWfjdCmI5nwLbKqKhSKB15JBdRmh/Wz0Gi1qOvER
x9wS5c/1pMr1ARcVUvz2425ZNV77AAQMGUZpLxP9N6QWK39u4VemoecdPfNYv/tt
qk1cJFO1aNNmIMrDzBZEzQH/Mf4QbiqsaSvuVay8mjVEW3she4FbcrhNnhlm3PS7
XOm0UF2TiCjrM4enCI2XhTzKnSxONiM8KubKEAEOXPDAYGRwn+dik30qYwT5kMbG
tzggHPsiwkBUDEcNeMuMGRKNxP3i03DA4wGSJZu3A61TcYVLihj9hEDnybe7Dw0h
eNmyqoqp/0gr89rxlAANNwIDAQABoAAwDQYJKoZIhvcNAQEFBQADggEBAEbyXe6f
aBGbaSldlIceYyxIXVqBRwVuE22vvk6to1f+QYrWj+4IexD0TBdfpcpKATnOjqEH
sbksB0HOKZmFDCqNZamw1458DtdtSPpOn5EyX9BX6K2hExmj5CV1vEORB8dQ4lBi
zjrpAOh422NQ3galu1vfrPVvRS8lN4t+zJUlBoCUwPlm5AmH88dJCXDHTxDrwxxv
6UPUROxE2p+1TyHueUmfMKvjySnt8IIfoEvz4q/EouIbL2lDJwXOwX+1fx4Rva6t
bx1hmt5Eihy1lORQR4PE4xaOP5TCqtxP0+snuGqRuBHhrDk4mowWEJbvFWlONT5H
CsajqZag/Aoxv/Y=
-----END CERTIFICATE REQUEST-----"

    @enc_cert = File.read "#{keys_path}/own_enc_cert.pem"
    @enc_private_key = OpenSSL::PKey::RSA.new File.read(
      "#{keys_path}/enc_private_key.pem"
    )

    @params = {
      bank: :danske,
      enc_cert: OpenSSL::X509::Certificate.new(@enc_cert),
      command: :create_certificate,
      customer_id: '360817',
      environment: 'customertest',
      key_generator_type: 'software',
      encryption_cert_pkcs10: OpenSSL::X509::Request.new(encryptpkcs),
      signing_cert_pkcs10: OpenSSL::X509::Request.new(signingpkcs),
      pin: '1234'
    }

    @cert_request = Sepa::SoapBuilder.new(@params)

    @doc = Nokogiri::XML(@cert_request.to_xml)

    # Namespaces
    @pkif = 'http://danskebank.dk/PKI/PKIFactoryService'
    @dsig = 'http://www.w3.org/2000/09/xmldsig#'
    @xenc = 'http://www.w3.org/2001/04/xmlenc#'
  end

  def test_get_certificate_soap_template_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    template = File.read("#{@templates_path}/create_certificate.xml")
    digest = Base64.encode64(sha1.digest(template)).strip
    assert_equal digest, "7xfCxrQo+BxrOYVmY/EV9lkhY7Y="
  end

  def test_should_raise_error_if_command_missing
    @params.delete(:command)

    assert_raises(ArgumentError) do
      Sepa::SoapBuilder.new(@params)
    end
  end

  def test_sender_id_is_properly_set
    sender_id = @doc.at("SenderId", "xmlns" => @pkif).content
    assert_equal sender_id, @params[:customer_id]
  end

  def test_customer_id_is_properly_set
    customer_id = @doc.at("CustomerId", "xmlns" => @pkif).content
    assert_equal customer_id, @params[:customer_id]
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
    embedded_cert = @doc.at("X509Certificate",
                            'xmlns' => @dsig).content.gsub(/\s+/, "")

    actual_cert = @enc_cert
    actual_cert = actual_cert.split('-----BEGIN CERTIFICATE-----')[1]
    actual_cert = actual_cert.split('-----END CERTIFICATE-----')[0]
    actual_cert.gsub!(/\s+/, "")

    assert_equal embedded_cert, actual_cert
  end

  def test_encrypted_key_is_added_properly_and_can_be_decrypted
    enc_key = @doc.css("CipherValue", 'xmlns' => @xenc)[0].content
    enc_key = Base64.decode64(enc_key)
    assert @enc_private_key.private_decrypt(enc_key)
  end

  def test_encypted_data_is_added_properly_and_can_be_decrypted
    enc_key = @doc.css("CipherValue", 'xmlns' => @xenc)[0].content
    enc_key = Base64.decode64(enc_key)
    key = @enc_private_key.private_decrypt(enc_key)

    encypted_data = @doc.css("CipherValue", 'xmlns' => @xenc)[1].content
    encypted_data = Base64.decode64(encypted_data)
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
    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(@doc)
    end
  end
end
