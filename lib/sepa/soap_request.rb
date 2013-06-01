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
      load_body(@command)
      set_node_contents
      sign.to_xml
    end

    private

      def load_body(command)
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
        @soap = Nokogiri::XML(body_template)
        body_template.close
      end

      def load_header_template
        header_template = File.open(
          File.expand_path('../xml_templates/soap/header.xml', __FILE__)
        )
        header = Nokogiri::XML(header_template)
        header_template.close
        header
      end

      def set_ar(ar)
        @soap.xpath(
          "//bxd:ApplicationRequest", 'bxd' => 'http://model.bxd.fi'
        ).first.content = ar.get_as_base64
      end

      def set_sender_id(sender_id)
        @soap.xpath(
          "//bxd:SenderId", 'bxd' => 'http://model.bxd.fi'
        ).first.content = sender_id
      end

      def set_request_id
        @soap.xpath(
          "//bxd:RequestId", 'bxd' => 'http://model.bxd.fi'
        ).first.content = SecureRandom.hex(17)
      end

      def set_timestamp
        @soap.xpath(
          "//bxd:Timestamp", 'bxd' => 'http://model.bxd.fi'
          ).first.content = Time.now.iso8601
      end

      def set_language(language)
        @soap.xpath(
          "//bxd:Language", 'bxd' => 'http://model.bxd.fi'
          ).first.content = language
      end

      def set_user_agent(user_agent)
        @soap.xpath(
          "//bxd:UserAgent", 'bxd' => 'http://model.bxd.fi'
          ).first.content = user_agent
      end

      def set_receiver_id(receiver_id)
        @soap.xpath(
          "//bxd:ReceiverId", 'bxd' => 'http://model.bxd.fi'
          ).first.content = receiver_id
      end

      def set_node_contents
        set_ar(@ar)
        set_sender_id(@customer_id)
        set_request_id
        set_timestamp
        set_language(@language)
        set_user_agent("Sepa Transfer Library version " + VERSION)
        set_receiver_id(@target_id)
      end

      # Sign the soap message body using detached signature
      def sign
        header = load_header_template

        # Add header timestamps
        created_node = header.xpath("//wsu:Created", 'wsu' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd').first
        created_node.content = Time.now.iso8601
        expires_node = header.xpath("//wsu:Expires", 'wsu' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd').first
        expires_node.content = (Time.now + 3600).iso8601

        # Take digest from header timestamps
        timestamp_node = header.xpath("//wsu:Timestamp", 'wsu' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd').first
        sha1 = OpenSSL::Digest::SHA1.new
        digestbin = sha1.digest(timestamp_node.canonicalize(mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,with_comments=false))
        digest = Base64.encode64(digestbin)
        timestamp_digest_node = header.xpath("//dsig:Reference[@URI='#dsfg8sdg87dsf678g6dsg6ds7fg']/dsig:DigestValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
        timestamp_digest_node.content = digest.gsub(/\s+/, "")

        # Take digest from soap request body, base64 code it and put it to the signature
        body = @soap.xpath("//env:Body", 'env' => 'http://schemas.xmlsoap.org/soap/envelope/').first
        canonbody = body.canonicalize(mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,with_comments=false)
        sha1 = OpenSSL::Digest::SHA1.new
        digestbin = sha1.digest(canonbody)
        digest = Base64.encode64(digestbin)
        body_digest_node = header.xpath("//dsig:Reference[@URI='#sdf6sa7d86f87s6df786sd87f6s8fsda']/dsig:DigestValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
        body_digest_node.content = digest.gsub(/\s+/, "")

        # Sign SignedInfo element with private key and add it to the correct field
        signed_info_node = header.xpath("//dsig:SignedInfo", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
        canon_signed_info = signed_info_node.canonicalize(mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,with_comments=false)
        digest_sign = OpenSSL::Digest::SHA1.new
        signature = @private_key.sign(digest_sign, canon_signed_info)
        signature_base64 = Base64.encode64(signature).gsub(/\s+/, "")

        # Add the base64 coded signature to the signature element
        signature_node = header.xpath("//dsig:SignatureValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
        signature_node.content = signature_base64

        # Format the certificate and add the it to the certificate element
        cert_formatted = @cert.to_s.split('-----BEGIN CERTIFICATE-----')[1].split('-----END CERTIFICATE-----')[0].gsub(/\s+/, "")
        cert_node = header.xpath("//wsse:BinarySecurityToken", 'wsse' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd').first
        cert_node.content = cert_formatted

        # Merge the header and body
        header.root.add_child(@soap.xpath("//env:Body", 'env' => 'http://schemas.xmlsoap.org/soap/envelope/').first)

        header
      end
  end
end
