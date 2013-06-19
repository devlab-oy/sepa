require File.expand_path('../../test_helper.rb', __FILE__)

class DanskeCertRequestTest < MiniTest::Test
  def setup
    @schemapath = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)
    @templatepath = File.expand_path('../../../lib/sepa/xml_templates/application_request',__FILE__)
    @danske_keys_path = File.expand_path('../danske_test_keys', __FILE__)

    reqid = SecureRandom.random_number(1000).to_s<<SecureRandom.random_number(1000).to_s

    @danskecertparams = {
      bank: :danske,
      command: :create_certificate,
      wsdl: File.expand_path('../../../lib/sepa/wsdl/wsdl_danske_cert.xml',__FILE__),
      request_id: reqid,
      customer_id: 'ABC123',
      environment: 'customertest',
      key_generator_type: 'software',
      encryption_cert_pkcs10: OpenSSL::X509::Request.new(File.read ("#{@danske_keys_path}/encryption_pkcs.csr")).to_der,
      signing_cert_pkcs10: OpenSSL::X509::Request.new(File.read ("#{@danske_keys_path}/signing_pkcs.csr")).to_der,
      cert: OpenSSL::X509::Certificate.new(File.read ("#{@danske_keys_path}/danskeroot.pem")),
      pin: '1234'
    }

    @certrequest = Sepa::DanskeCertRequest.new(@danskecertparams)

    @xml = Nokogiri::XML(@certrequest.to_xml_unencrypted)
  end

  # def test_that_get_certificate_soap_template_is_unmodified
  #   sha1 = OpenSSL::Digest::SHA1.new
  #   template = File.read("#{@templatepath}/get_certificate.xml")
  #   digest = Base64.encode64(sha1.digest(template)).strip

  #   assert_equal digest, "iYJcoQAlXZj5Pp9vLlSROXxY3+k="
  # end

  def test_should_initialize_with_proper_params
    assert Sepa::DanskeCertRequest.new(@danskecertparams)
  end

  # def test_should_get_error_if_command_missing
  #   @danskecertparams.delete(:command)

  #   assert_raises(KeyError) do
  #     Sepa::DanskeCertRequest.new(@danskecertparams)
  #   end
  # end

  # def test_should_get_error_if_customer_id_missing
  #   @danskecertparams.delete(:customer_id)

  #   assert_raises(KeyError) do
  #     Sepa::DanskeCertRequest.new(@danskecertparams)
  #   end
  # end

  # def test_should_load_correct_template_with_get_certificate
  #   @danskecertparams[:command] = :get_certificate
  #   xml = Nokogiri::XML(Sepa::DanskeCertRequest.new(@danskecertparams).to_xml)

  #   assert xml.xpath('//cer:getCertificatein', 'cer' => 'http://bxd.fi/CertificateService').first
  # end

  # def test_should_raise_error_if_command_not_correct
  #   @danskecertparams[:command] = :wrong_command
  #   # This will be KeyError until different way to choose between soap/certrequests is implemented in applicationrequest class
  #   assert_raises(KeyError) do
  #     soap = Sepa::DanskeCertRequest.new(@danskecertparams).to_xml
  #   end
  # end

  # def test_timestamp_is_set_correctly
  #   timestamp_node = @xml.xpath(
  #     "//cer:Timestamp", 'cer' => 'http://bxd.fi/CertificateService'
  #   ).first

  #   timestamp = Time.strptime(timestamp_node.content, '%Y-%m-%dT%H:%M:%S%z')

  #   assert timestamp <= Time.now && timestamp > (Time.now - 60)
  # end

  # def test_application_request_should_be_inserted_properly
  #   ar_node = @xml.xpath(
  #     "//cer:ApplicationRequest", 'cer' => 'http://bxd.fi/CertificateService'
  #   ).first

  #   ar_doc = Nokogiri::XML(Base64.decode64(ar_node.content))

  #   assert ar_doc.respond_to?(:canonicalize)
  #   assert_equal ar_doc.at_css("CustomerId").content, @danskecertparams[:customer_id]
  # end

  # def test_should_validate_against_schema
  #   Dir.chdir(@schemapath) do
  #     xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
  #     assert xsd.valid?(@xml)
  #   end
  # end
end
