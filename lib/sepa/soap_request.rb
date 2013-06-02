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

      @body = load_body_template(@command)
      @header = load_header_template
    end

    def to_xml
      construct(
        @command,
        @ar,
        @sender_id,
        @lang,
        @receiver_id,
        @private_key,
        @cert
      ).to_xml
    end

    private

      def construct(command, ar, sender_id, lang, receiver_id, private_key, cert)
        set_body_contents(ar, sender_id, lang, receiver_id)
        process_header(private_key, cert)
        merge_header_and_body(@header, @body)
      end

      def load_body_template(command)
        case command
        when :download_file_list
          path = File.expand_path(
            '../xml_templates/soap/download_file_list.xml', __FILE__
          )
        when :get_user_info
          path = File.expand_path(
            '../xml_templates/soap/get_user_info.xml', __FILE__
          )
        when :upload_file
          path = File.expand_path(
            '../xml_templates/soap/upload_file.xml', __FILE__
          )
        when :download_file
          path = File.expand_path(
            '../xml_templates/soap/download_file.xml', __FILE__
          )
        else
          raise LoadError, "Could not load soap request template because the" \
            "command was unrecognised"
        end

        body_template = File.open(path)
        body = Nokogiri::XML(body_template)
        body_template.close

        body
      end

      def set_body_contents(ar, sender_id, lang, receiver_id)
        set_node(@body, 'bxd|ApplicationRequest', ar)
        set_node(@body, 'bxd|SenderId', sender_id)
        set_node(@body, 'bxd|RequestId', SecureRandom.hex(17))
        set_node(@body, 'bxd|Timestamp', Time.now.iso8601)
        set_node(@body, 'bxd|Language', lang)
        set_node(@body, 'bxd|UserAgent', "Sepa Transfer Library version " + VERSION)
        set_node(@body, 'bxd|ReceiverId', receiver_id)
      end

      def load_header_template
        header_template = File.open(
          File.expand_path('../xml_templates/soap/header.xml', __FILE__)
        )
        header = Nokogiri::XML(header_template)
        header_template.close
        header
      end

      def process_header(private_key, cert)
        add_header_created_timestamp(Time.now.iso8601)
        add_header_expires_timestamp((Time.now + 3600).iso8601)
        add_header_timestamps_digest(calculate_header_timestamps_digest)
        add_soap_body_digest(calculate_soap_body_digest)
        add_signature(calculate_signature(private_key))
        add_certificate(cert)
      end

      def set_node(doc, node, value)
        doc.at_css(node).content = value
      end

      def add_header_created_timestamp(timestamp)
        @header.xpath(
          "//wsu:Created", 'wsu' => 'http://docs.oasis-open.org/wss/2004/01/o' \
          'asis-200401-wss-wssecurity-utility-1.0.xsd'
        ).first.content = timestamp
      end

      def add_header_expires_timestamp(expiration_time)
        @header.xpath(
          "//wsu:Expires", 'wsu' => 'http://docs.oasis-open.org/wss/2004/01/o' \
          'asis-200401-wss-wssecurity-utility-1.0.xsd'
        ).first.content = expiration_time
      end

      def calculate_header_timestamps_digest
        sha1 = OpenSSL::Digest::SHA1.new

        timestamp_node = @header.xpath(
          "//wsu:Timestamp", 'wsu' => 'http://docs.oasis-open.org/wss/2004/01' \
          '/oasis-200401-wss-wssecurity-utility-1.0.xsd'
        ).first

        canon_timestamp_node = timestamp_node.canonicalize(
          mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,
          with_comments=false
        )

        Base64.encode64(sha1.digest(canon_timestamp_node)).gsub(/\s+/, "")
      end

      def add_header_timestamps_digest(digest)
        @header.xpath(
          "//dsig:Reference[@URI='#dsfg8sdg87dsf678g6dsg6ds7fg']/dsig:DigestV" \
          "alue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
        ).first.content = digest
      end

      def calculate_soap_body_digest
        sha1 = OpenSSL::Digest::SHA1.new

        body = @body.xpath(
          "//env:Body", 'env' => 'http://schemas.xmlsoap.org/soap/envelope/'
        ).first

        canon_body = body.canonicalize(
          mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,
          with_comments=false
        )

        Base64.encode64(sha1.digest(canon_body)).gsub(/\s+/, "")
      end

      def add_soap_body_digest(digest)
        @header.xpath(
          "//dsig:Reference[@URI='#sdf6sa7d86f87s6df786sd87f6s8fsda']/dsig:Di" \
          "gestValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
        ).first.content = digest
      end

      def calculate_signature(private_key)
        sha1 = OpenSSL::Digest::SHA1.new

        signed_info_node = @header.xpath(
          "//dsig:SignedInfo", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
        ).first

        canon_signed_info = signed_info_node.canonicalize(
          mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,
          with_comments=false
        )

        signature = private_key.sign(sha1, canon_signed_info)

        Base64.encode64(signature).gsub(/\s+/, "")
      end

      def add_signature(signature)
        @header.xpath(
          "//dsig:SignatureValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
        ).first.content = signature
      end

      def add_certificate(cert)
        cert = cert.to_s
        cert = cert.split('-----BEGIN CERTIFICATE-----')[1]
        cert = cert.split('-----END CERTIFICATE-----')[0]
        cert = cert.gsub(/\s+/, "")

        @header.xpath(
          "//wsse:BinarySecurityToken", 'wsse' => 'http://docs.oasis-open.org' \
          '/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'
        ).first.content = cert
      end

      def merge_header_and_body(header, body)
        body = body.xpath(
          "//env:Body", 'env' => 'http://schemas.xmlsoap.org/soap/envelope/'
        ).first

        header.root.add_child(body)

        header
      end
  end
end
