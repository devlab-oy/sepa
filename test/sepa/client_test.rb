require File.expand_path('../../test_helper.rb', __FILE__)

class ClientTest < MiniTest::Test
  def setup
    @schemas_path = File.expand_path('../../../lib/sepa/xml_schemas',__FILE__)

    wsdl_path = File.expand_path('../../../lib/sepa/wsdl/wsdl_nordea.xml',
                                 __FILE__)

    keys_path = File.expand_path('../nordea_test_keys', __FILE__)

    private_key = OpenSSL::PKey::RSA.new File.read "#{keys_path}/nordea.key"
    cert = OpenSSL::X509::Certificate.new File.read "#{keys_path}/nordea.crt"

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
      wsdl: wsdl_path,
      content: Base64.encode64("Kurppa"),
      file_reference: "11111111A12006030329501800000014"
    }

    observer = Class.new {
      def notify(operation_name, builder, globals, locals)
        @operation_name = operation_name
        @builder = builder
        @globals = globals
        @locals  = locals

        HTTPI::Response.new(200,
                            { "Reponse is actually" => "the request, w0000t" },
                            locals[:xml])
      end
    }.new

    Savon.observers << observer
  end

  def test_example_response_is_unmodified
    sha1 = OpenSSL::Digest::SHA1.new
    test_response = File.read(
      File.expand_path('../test_responses/get_user_info.xml', __FILE__)
    )
    digest = Base64.encode64(sha1.digest(test_response)).strip

    assert_equal digest, 'FBJEWs1drKGWBERigYeRNZuoiaM='
  end

  def test_should_initialize_with_proper_params
    assert Sepa::Client.new(@params)
  end

  def test_should_raise_error_if_wsdl_missing
    @params.delete(:wsdl)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_command_missing
    @params.delete(:command)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_private_key_missing
    @params.delete(:private_key)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_cert_missing
    @params.delete(:cert)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_customer_id_missing
    @params.delete(:customer_id)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_environment_missing
    @params.delete(:environment)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_target_id_missing
    @params.delete(:target_id)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_raise_error_if_language_missing
    @params.delete(:language)

    assert_raises(KeyError) { Sepa::Client.new(@params) }
  end

  def test_should_get_ar_as_xml
    observer = Class.new {
      def notify(*)
        test_response = File.read(
          File.expand_path('../test_responses/get_user_info.xml', __FILE__)
        )

        HTTPI::Response.new(200, { "Example" => "response" }, test_response)
      end
    }.new

    Savon.observers << observer

    client = Sepa::Client.new(@params)
    ar = Nokogiri::XML(client.ar_to_xml)

    assert_equal ar.at_css('c2b|CustomerId').content, '11111111'
  end

  # The response from savon will be the request to check that a proper request
  # was made in the following four tests
  def test_should_send_proper_request_with_get_user_info
    client = Sepa::Client.new(@params)
    response = client.send

    assert_equal response.body.keys[0], :get_user_infoin

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(Nokogiri::XML(response.to_xml))
    end
  end

  def test_should_send_proper_request_with_download_file_list
    @params[:command] = :download_file_list
    client = Sepa::Client.new(@params)
    response = client.send

    assert_equal response.body.keys[0], :download_file_listin

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(Nokogiri::XML(response.to_xml))
    end
  end

  def test_should_send_proper_request_with_download_file
    @params[:command] = :download_file
    client = Sepa::Client.new(@params)
    response = client.send

    assert_equal response.body.keys[0], :download_filein

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(Nokogiri::XML(response.to_xml))
    end
  end

  def test_should_send_proper_request_with_upload_file
    @params[:command] = :upload_file
    client = Sepa::Client.new(@params)
    response = client.send

    assert_equal response.body.keys[0], :upload_filein

    Dir.chdir(@schemas_path) do
      xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
      assert xsd.valid?(Nokogiri::XML(response.to_xml))
    end
  end
end
