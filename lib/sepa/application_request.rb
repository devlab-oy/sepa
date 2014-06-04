module Sepa
  class ApplicationRequest
    def initialize(params)
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
        @time = Time.now.utc.iso8601
      end
    end

    def get_as_base64
      load_template
      set_nodes_contents
      # No signature for Certificate Requests
      if @command != :get_certificate && @command != :get_bank_certificate &&
          @command != :create_certificate
        process_signature
      end

      if @command == :create_certificate
        @ar
      else
        Base64.encode64(@ar.to_xml)
      end
    end

    private

      # Loads the application request template according to the command
      def load_template
        case @command

        when :get_certificate
          path = "#{AR_TEMPLATE_PATH}/get_certificate.xml"
        when :download_file_list
          path = "#{AR_TEMPLATE_PATH}/download_file_list.xml"
        when :get_user_info
          path = "#{AR_TEMPLATE_PATH}/get_user_info.xml"
        when :upload_file
          path = "#{AR_TEMPLATE_PATH}/upload_file.xml"
        when :download_file
          path = "#{AR_TEMPLATE_PATH}/download_file.xml"
        when :get_bank_certificate
          path = "#{AR_TEMPLATE_PATH}/danske_get_bank_certificate.xml"
        when :create_certificate
          path = "#{AR_TEMPLATE_PATH}/create_certificate.xml"
        else
          fail ArgumentError
        end

        @ar = Nokogiri::XML(File.open(path))
      end


      def set_node(node, value)
        @ar.at_css(node).content = value
      end

      def set_node_b(node, value)
        set_node node, Base64.encode64(value)
      end

      def pretty_command
        @command.to_s.split(/[\W_]/).map {|c| c.capitalize}.join
      end

      def pkcs10der
        @encryption_cert_pkcs10.to_der
      end

      def signingder
        @signing_cert_pkcs10.to_der
      end

      def set_nodes_contents
        unless @command == :get_bank_certificate || @command == :create_certificate
          set_common_nodes
        end

        case @command
          when :create_certificate
            set_create_certificate_nodes
          when :get_certificate
            set_get_certificate_nodes
          when :download_file_list
            set_download_file_list_nodes
          when :download_file
            set_download_file_nodes
          when :upload_file
            set_upload_file_nodes
          when :get_bank_certificate
            set_get_bank_certificate_nodes
        end
      end

    def set_download_file_nodes
      set_download_file_list_nodes
      set_node("FileReference", @file_reference)
    end

    def set_get_bank_certificate_nodes
      set_node("elem|BankRootCertificateSerialNo", @bank_root_cert_serial)
      set_node("elem|Timestamp", @time)
      set_node("elem|RequestId", @request_id)
    end

      def set_upload_file_nodes
      set_node("Content", Base64.encode64(@content))
      set_node("FileType", @file_type)
      set_node("TargetId", @target_id)
    end

      def set_download_file_list_nodes
      set_node("Status", @status)
      set_node("TargetId", @target_id)
      set_node("FileType", @file_type)
    end

      def set_get_certificate_nodes
      set_node("Service", @service)
      set_node("Content", @csr)
      set_node("HMAC", hmac.chop)
    end

      def set_create_certificate_nodes
      set_node("tns|CustomerId", @customer_id)
      set_node("tns|KeyGeneratorType", @key_generator_type)
      set_node_b("tns|EncryptionCertPKCS10", pkcs10der)
      set_node_b("tns|SigningCertPKCS10", signingder)
      set_node("tns|Timestamp", @time)
      set_node("tns|RequestId", @request_id)
      set_node("tns|Environment", @environment)
      set_node("tns|PIN", @pin)
    end

      def set_common_nodes
      set_node("CustomerId", @customer_id)
      set_node("Timestamp", @time)
      set_node("Environment", @environment)
      set_node("SoftwareId", "Sepa Transfer Library version #{VERSION}")
      set_node("Command", pretty_command)
    end

      def hmac
        return "" if @pin.nil? || @csr.nil?
        OpenSSL::HMAC.digest('sha1',@pin,@csr)
      end

      def remove_node(doc, node, xmlns)
        doc.at_css("xmlns|#{node}", 'xmlns' => xmlns).remove
      end

      def add_node_to_root(doc, node)
        doc.root.add_child(node)
      end

      def calculate_digest(doc)
        sha1 = OpenSSL::Digest::SHA1.new
        Base64.encode64(sha1.digest(doc.canonicalize))
      end

      def add_value_to_signature(node, value)
        node = @ar.at_css("dsig|#{node}",
                          'dsig' => 'http://www.w3.org/2000/09/xmldsig#')
        node.content = value
      end

      def calculate_signature
        sha1 = OpenSSL::Digest::SHA1.new
        node = @ar.at_css("dsig|SignedInfo",
                          'dsig' => 'http://www.w3.org/2000/09/xmldsig#')
        signature = @private_key.sign(sha1, node.canonicalize)
        Base64.encode64(signature)
      end

      def format_cert(cert)
        cert = cert.to_s
        cert = cert.split('-----BEGIN CERTIFICATE-----')[1]
        cert = cert.split('-----END CERTIFICATE-----')[0]
        cert.gsub!(/\s+/, "")
      end

      def process_signature
        signature_node = remove_node(@ar,
                                     'Signature',
                                     'http://www.w3.org/2000/09/xmldsig#')
        digest = calculate_digest(@ar)
        add_node_to_root(@ar, signature_node)
        add_value_to_signature('DigestValue', digest)
        signature = calculate_signature
        add_value_to_signature('SignatureValue', signature)
        add_value_to_signature('X509Certificate',format_cert(@cert))
      end
    end
end
