module Sepa
  class DanskeCertRequest
    def initialize(params)
      @command = params.fetch(:command)
      @sender_id = params.fetch(:customer_id)
      @request_id = params.fetch(:request_id)
      @ar = ApplicationRequest.new(params).get_as_base64

      template_path = File.expand_path('../xml_templates/soap/', __FILE__)

      @body = load_body_template(template_path, @command)


    end

    def to_xml
      construct(@body, @command, @ar, @sender_id, @request_id).to_xml
    end

    private

      def construct(body, command, ar, sender_id, request_id)
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

      def set_body_contents(body, ar, sender_id, request_id)
        set_node(body, 'pkif|SenderId', sender_id)
        set_node(body, 'pkif|CustomerId', sender_id)
        set_node(body, 'pkif|RequestId', request_id)
        set_node(body, 'pkif|Timestamp', Time.now.iso8601)
        set_node(body, 'pkif|InterfaceVersion', 1)
        #set_node(body, 'pkif|CreateCertificateIn', ar)

        #puts body.to_xml
        #body
      end

      def set_node(doc, node, value)
        doc.at_css(node).content = value
      end

      def add_request_to_soap(ar, body)
        ar = ar.at_css('tns|CreateCertificateRequest')
        body.at_css('pkif|CreateCertificateIn').add_child(ar)
        body
      end
  end
end
