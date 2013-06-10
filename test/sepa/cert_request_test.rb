require File.expand_path('../../test_helper.rb', __FILE__)

class CertRequestTest < MiniTest::Test
  def setup
    @schemapath
    @templatepath
    keyspath = File.expand_path('../nordea_test_keys', __FILE__)

  # Test pin for nordea
  testpin = '1234567890'

  # Open Certificate Signing Request PKCS#10
  testcert = OpenSSL::X509::Request.new(File.read ("#{keyspath}/testcert.csr"))

  # Generate HMAC seal (SHA1 hash) with pin as key and PKCS#10 as message
  hmacseal = OpenSSL::HMAC.digest('sha1',testpin,testcert.to_der)

  # Assign the generated PKCS#10 to as payload (goes to Content element)
  payload = testcert.to_der

  # Assign the calculated HMAC seal as hmac (goes to HMAC element)
  hmac = hmacseal

  # The params hash is populated with the data that is needed for gem to function
  params = {
    # Command for CertificateService :get_certificate
    command: :get_certificate,

    # Unique customer ID
    customer_id: '11111111',

    # Set the environment to be either PRODUCTION or TEST
    environment: 'TEST',

    # The WSDL file used by nordea. Is identical between banks except for the address.
    wsdl: 'sepa/wsdl/wsdl_nordea_cert.xml',

    # The actual payload to send.
    content: payload,

    # HMAC seal
    hmac: hmac,

    # Selected service (For testing: service, For real: ISSUER)
    service: 'service'

  }

  @certrequest = Sepa::CertRequest.new(@params)

  @xml = Nokogiri::XML(@certrequest)
  end

  def test_should_initialize_with_proper_params
    assert Sepa::CertRequest.new(@params)
  end
end
