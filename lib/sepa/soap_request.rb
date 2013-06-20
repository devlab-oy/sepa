module Sepa
  class SoapRequest
    def initialize(params)
      @private_key = params.fetch(:private_key)
      @cert = params.fetch(:cert)
      @command = params.fetch(:command)
      @sender_id = params.fetch(:customer_id)
      @receiver_id = params.fetch(:target_id)
      @ar = ApplicationRequest.new(params).get_as_base64
      @lang = params.fetch(:language)

      template_path = File.expand_path('../xml_templates/soap/', __FILE__)

      @body = load_body_template(template_path, @command)
      @header = load_header_template(template_path)
    end

    def to_xml
      construct(@body, @header, @command, @ar, @sender_id, @lang, @receiver_id,
                @private_key, @cert).to_xml
    end

    private

      def construct(body, header, command, ar, sender_id, lang, receiver_id,
                    private_key, cert)
        set_body_contents(body, ar, sender_id, lang, receiver_id)
        process_header(header, private_key, cert)
        add_body_to_header(header, body)
      end

      def load_body_template(template_path, command)
        case command
        when :download_file_list
          path = "#{template_path}/download_file_list.xml"
        when :get_user_info
          path = "#{template_path}/get_user_info.xml"
        when :upload_file
          path = "#{template_path}/upload_file.xml"
        when :download_file
          path = "#{template_path}/download_file.xml"
        end

        body_template = File.open(path)
        body = Nokogiri::XML(body_template)
        body_template.close

        body
      end

      def set_body_contents(body, ar, sender_id, lang, receiver_id)
        set_node(body, 'bxd|ApplicationRequest', ar)
        set_node(body, 'bxd|SenderId', sender_id)
        set_node(body, 'bxd|RequestId', SecureRandom.hex(17))
        set_node(body, 'bxd|Timestamp', Time.now.iso8601)
        set_node(body, 'bxd|Language', lang)
        set_node(body, 'bxd|UserAgent',
                 "Sepa Transfer Library version " + VERSION)
        set_node(body, 'bxd|ReceiverId', receiver_id)
      end

      def load_header_template(template_path)
        header_template = File.open("#{template_path}/header.xml")
        header = Nokogiri::XML(header_template)
        header_template.close
        header
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
