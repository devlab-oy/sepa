module Sepa
  class SoapRequest
    def initialize(params)
      @private_key = params.fetch(:private_key)
      @cert = params.fetch(:cert)
      @command = params.fetch(:command)
      @customer_id = params.fetch(:customer_id)
      @target_id = params.fetch(:target_id)
      @ar = ApplicationRequest.new(params)
      @language = params.fetch(:language)
    end

    def to_xml
      construct_soap_request.to_xml
    end

    private

      def construct_soap_request
        load_body_template(@command)
        set_body_contents
        load_header_template
        process_header
        merge_header_and_body(@header, @body)
      end

      def load_body_template(command)
        # Selecting which soap request template to load
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
        @body = Nokogiri::XML(body_template)
        body_template.close
      end

      def set_body_contents
        set_ar(@ar)
        set_sender_id(@customer_id)
        set_request_id
        set_timestamp
        set_language(@language)
        set_user_agent("Sepa Transfer Library version " + VERSION)
        set_receiver_id(@target_id)
      end

      def load_header_template
        header_template = File.open(
          File.expand_path('../xml_templates/soap/header.xml', __FILE__)
        )
        @header = Nokogiri::XML(header_template)
        header_template.close
      end

      def process_header
        add_header_created_timestamp
        add_header_expires_timestamp (Time.now + 3600).iso8601
        add_header_timestamps_digest(calculate_header_timestamps_digest)
        add_soap_body_digest(calculate_soap_body_digest)
        add_signature(calculate_signature(@private_key))
        add_certificate(@cert)
      end

      def set_ar(ar)
        @body.xpath(
          "//bxd:ApplicationRequest", 'bxd' => 'http://model.bxd.fi'
        ).first.content = ar.get_as_base64
      end

      def set_sender_id(sender_id)
        @body.xpath(
          "//bxd:SenderId", 'bxd' => 'http://model.bxd.fi'
        ).first.content = sender_id
      end

      def set_request_id
        @body.xpath(
          "//bxd:RequestId", 'bxd' => 'http://model.bxd.fi'
        ).first.content = SecureRandom.hex(17)
      end

      def set_timestamp
        @body.xpath(
          "//bxd:Timestamp", 'bxd' => 'http://model.bxd.fi'
        ).first.content = Time.now.iso8601
      end

      def set_language(language)
        @body.xpath(
          "//bxd:Language", 'bxd' => 'http://model.bxd.fi'
        ).first.content = language
      end

      def set_user_agent(user_agent)
        @body.xpath(
          "//bxd:UserAgent", 'bxd' => 'http://model.bxd.fi'
        ).first.content = user_agent
      end

      def set_receiver_id(receiver_id)
        @body.xpath(
          "//bxd:ReceiverId", 'bxd' => 'http://model.bxd.fi'
        ).first.content = receiver_id
      end

      def add_header_created_timestamp
        @header.xpath(
          "//wsu:Created", 'wsu' => 'http://docs.oasis-open.org/wss/2004/01/o' \
          'asis-200401-wss-wssecurity-utility-1.0.xsd'
        ).first.content = Time.now.iso8601
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
