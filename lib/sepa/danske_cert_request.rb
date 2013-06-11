module Sepa
  class DanskeCertRequest
    def initialize(params)
      @command = params.fetch(:command)
      @sender_id = params.fetch(:customer_id)
      @request_id = params.fetch(:request_id)
      @cert = params.fetch(:cert)
      @ar = ApplicationRequest.new(params).get_as_base64

      template_path = File.expand_path('../xml_templates/soap/', __FILE__)

      @body = load_body_template(template_path, @command)

      @encrypted_request = load_encrypted_request_template(template_path, @command)
    end

    def to_xml
      construct(@body, @command, @ar, @sender_id, @request_id).to_xml
    end

    private

      def construct(body, command, ar, sender_id, request_id, cert, encrypted_request)
        set_body_contents(body, ar, sender_id, request_id)
        add_request_to_soap(ar, body)
      end

      def load_body_template(template_path, command)
        case command
        when :create_certificate
          path = "#{template_path}/create_certificate.xml"
        else
          fail LoadError, "Could not load soap request template because the" \
            "command was unrecognised"
        end

        body_template = File.open(path)
        body = Nokogiri::XML(body_template)
        body_template.close

        body
      end

      def load_encrypted_request_template(template_path, command)
        case command
        when :get_certificate
          path = "#{template_path}/danske_encrypted_request.xml"
        else
          fail LoadError, "Could not load soap request template because the" \
            "command was unrecognised"
        end

        encrypted_request_template = File.open(path)
        encrypted_request = Nokogiri::XML(encrypted_request_template)
        encrypted_request_template.close

        encrypted_request
      end

      def set_body_contents(body, ar, sender_id, request_id)
        set_node(body, 'pkif|SenderId', sender_id)
        set_node(body, 'pkif|CustomerId', sender_id)
        set_node(body, 'pkif|RequestId', request_id)
        set_node(body, 'pkif|Timestamp', Time.now.iso8601)
        set_node(body, 'pkif|InterfaceVersion', 1)
      end

      def set_node(doc, node, value)
        doc.at_css(node).content = value
      end

      def add_request_to_soap(ar, body, cert, encrypted_request)
        ar = ar.at_css('tns|CreateCertificateRequest')
        #ar = encrypt_application_request(ar, cert, encrypted_request)
        body.at_css('pkif|CreateCertificateIn').add_child(ar)
        body
      end

      def encrypt_application_request(ar, cert, encrypted_request)
        set_node(encrypted_request, 'dsig|X509Certificate', Base64.encode64(cert.to_der))
        set_node(encrypted_request, 'xenc|CipherValue', "hello")
        set_node(encrypted_request, '', Base64.encode64(cert.encrypt(ar))
      end
  end
end
