module Sepa
  class DanskeCertRequest
    def initialize(params)
      @command = params.fetch(:command)
      @sender_id = params.fetch(:customer_id)
      @receiver_id = params.fetch(:target_id)
      @ar = ApplicationRequest.new(params).get_as_base64

      template_path = File.expand_path('../xml_templates/soap/', __FILE__)

      @body = load_body_template(template_path, @command)
    end

    def to_xml
      construct(@body, @command, @ar, @sender_id).to_xml
    end

    private

      def construct(body, command, ar, sender_id)
        set_body_contents(body, ar, sender_id, lang, receiver_id)
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

      def set_body_contents(body, ar, sender_id)
        set_node(body, 'pkif|CreateCertificateIn', ar)
        set_node(body, 'pkif|SenderId', sender_id)
        set_node(body, 'pkif|CustomerId', sender_id)
        set_node(body, 'pkif|RequestId', SecureRandom.hex(17))
        set_node(body, 'pkif|Timestamp', Time.now.iso8601)
        set_node(body, 'pkif|InterfaceVersion', '1')
      end

      def process_header(header, private_key, cert)
        set_node(header, 'wsu|Created', Time.now.iso8601)

        set_node(header, 'wsu|Expires', (Time.now + 3600).iso8601)

        timestamp_digest = calculate_digest(@header,'wsu|Timestamp')
        set_node(header,'dsig|Reference[URI="#dsfg8sdg87dsf678g6dsg6ds7fg"]' \
                 ' dsig|DigestValue', timestamp_digest)

        body_digest = calculate_digest(@body, 'env|Body')
        set_node(header,'dsig|Reference[URI="#sdf6sa7d86f87s6df786sd87f6s8fsd'\
                 'a"] dsig|DigestValue', body_digest)

        signature = calculate_signature(header, 'dsig|SignedInfo', private_key)
        set_node(header, 'dsig|SignatureValue', signature)

        formatted_cert = format_cert(cert)
        set_node(header, 'wsse|BinarySecurityToken', formatted_cert)
      end

      def set_node(doc, node, value)
        doc.at_css(node).content = value
      end

      def calculate_digest(doc, node)
        sha1 = OpenSSL::Digest::SHA1.new

        node = doc.at_css(node)

        canon_node = node.canonicalize(
          mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
          inclusive_namespaces=nil,with_comments=false
        )

        Base64.encode64(sha1.digest(canon_node)).gsub(/\s+/, "")
      end

      def calculate_signature(doc, node, private_key)
        sha1 = OpenSSL::Digest::SHA1.new

        node = doc.at_css(node)

        canon_signed_info_node = node.canonicalize(
          mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,
          with_comments=false
        )

        signature = private_key.sign(sha1, canon_signed_info_node)

        Base64.encode64(signature).gsub(/\s+/, "")
      end

      def format_cert(cert)
        cert = cert.to_s
        cert = cert.split('-----BEGIN CERTIFICATE-----')[1]
        cert = cert.split('-----END CERTIFICATE-----')[0]
        cert.gsub!(/\s+/, "")
      end

      def add_body_to_header(header, body)
        body = body.at_css('env|Body')
        header.root.add_child(body)
        header
      end
  end
end
