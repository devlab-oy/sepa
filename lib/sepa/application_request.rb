module Sepa
  class ApplicationRequest
    def initialize(params)
      @command = params.fetch(:command)

      if !(@command == :get_certificate)
        @private_key = params.fetch(:private_key)
        @cert = params.fetch(:cert)
        @file_reference = params[:file_reference]
        @target_id = params[:target_id]
        @file_type = params[:file_type]
        @status = params[:status]
      else
        @service = params[:service]
        @hmac = params[:hmac]
      end

      @customer_id = params.fetch(:customer_id)
      @environment = params.fetch(:environment)
      @content = params[:content]
    end

    def get_as_base64
      load_template(@command)
      set_nodes_contents
      process_signature unless @command == :get_certificate
      Base64.encode64(@ar.to_xml)
    end

    private

      # Loads the application request template according to the command
      def load_template(command)
        template_dir = File.expand_path('../xml_templates/application_request',
                                        __FILE__)

        case command
        when :get_certificate
          path = "#{template_dir}/get_certificate.xml"
        when :download_file_list
          path = "#{template_dir}/download_file_list.xml"
        when :get_user_info
          path = "#{template_dir}/get_user_info.xml"
        when :upload_file
          path = "#{template_dir}/upload_file.xml"
        when :download_file
          path = "#{template_dir}/download_file.xml"
        else
          raise ArgumentError, 'Could not load application request template  '\
            'because command was unrecognised.'
        end

        @ar = Nokogiri::XML(File.read(path))
      end

      def set_node(node, value)
        @ar.at_css(node).content = value
      end

      # Set the nodes' contents according to the command
      def set_nodes_contents
        set_node("CustomerId", @customer_id)
        set_node("Timestamp", Time.now.iso8601)
        set_node("Environment", @environment)
        set_node("SoftwareId", "Sepa Transfer Library version #{VERSION}")
        set_node("Command",
                 @command.to_s.split(/[\W_]/).map {|c| c.capitalize}.join)

        case @command
        when :get_certificate
          set_node("Service", @service)
          set_node("Content", Base64.encode64(@content))
          set_node("HMAC", Base64.encode64(@hmac).chop)
        when :download_file_list
          set_node("Status", @status)
          set_node("TargetId", @target_id)
          set_node("FileType", @file_type)
        when :download_file
          set_node("Status", @status)
          set_node("TargetId", @target_id)
          set_node("FileType", @file_type)
          set_node("FileReference", @file_reference)
        when :upload_file
          set_node("Content", Base64.encode64(@content))
          set_node("FileType", @file_type)
          set_node("TargetId", @target_id)
        end
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

      def calculate_signature(private_key)
        sha1 = OpenSSL::Digest::SHA1.new
        node = @ar.at_css("dsig|SignedInfo",
                          'dsig' => 'http://www.w3.org/2000/09/xmldsig#')
        signature = private_key.sign(sha1, node.canonicalize)
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
        signature = calculate_signature(@private_key)
        add_value_to_signature('SignatureValue', signature)
        add_value_to_signature('X509Certificate',format_cert(@cert))
      end
  end
end
