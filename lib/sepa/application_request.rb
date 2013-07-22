module Sepa
  class ApplicationRequest
    def initialize(params)
      # Used by most, both Nordea and Danske
      @command = check_command(params.fetch(:command))
      @customer_id = params.fetch(:customer_id)
      @environment = params.fetch(:environment)
      @target_id = params[:target_id]
      @status = params[:status]
      @file_type = params[:file_type]
      @content = params[:content]
      @file_reference = params[:file_reference]

      # For signed Nordea application requests
      if @command != :get_certificate && @command != :create_certificate && @command != :get_bank_certificate
        @private_key = params.fetch(:private_key)
        @cert = params.fetch(:cert)
      elsif @command == :get_certificate || @command == :create_certificate || @command == :get_bank_certificate
        # Only for cert requests
        # Danske Bank Create Certificate
        @pin = params[:pin]
        @key_generator_type = params[:key_generator_type]
        @encryption_cert_pkcs10 = params[:encryption_cert_pkcs10]
        @signing_cert_pkcs10 = params[:signing_cert_pkcs10]
        @request_id = params[:request_id] # For Danske Bank PKI
        # Danske Bank Get Bank Certificate
        @bank_root_cert_serial = params[:bank_root_cert_serial]
        # Nordea Bank
        @service = params[:service]
      end
      # Only for Nordea Get Certificate
      if @command == :get_certificate
        @pin = params[:pin]
        @csr = params[:csr]
        # Creates a hmac seal with the CSR and PIN-code
        params[:hmac] = create_hmac_seal(@pin,@csr)
        @hmac = params[:hmac]
      end
    end

    def get_as_base64
      load_template(@command)
      set_nodes_contents
      # No signature for Certificate Requests
      if @command != :get_certificate && @command != :create_certificate && @command != :get_bank_certificate
        process_signature
      end
      # Danske Certificate Request is going to be encrypted and encoded afterwards
      if @command == :create_certificate
        @ar
      else
        Base64.encode64(@ar.to_xml)
      end
    end

    private

      def check_command(command)
        valid_commands = [:get_certificate, :create_certificate, :download_file_list, :download_file, :get_user_info, :upload_file, :download_file, :get_bank_certificate]
        unless valid_commands.include?(command)
          fail ArgumentError, "You didn't provide a proper command. " \
          "Acceptable values are #{valid_commands.inspect}"
        else
          command
        end
      end
      # Loads the application request template according to the command
      def load_template(command)
        template_dir = File.expand_path('../xml_templates/application_request', __FILE__)

        case command

        when :create_certificate
          path = "#{template_dir}/create_certificate.xml"
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
        when :get_bank_certificate
          path = "#{template_dir}/danske_get_bank_certificate.xml"
        end

        @ar = Nokogiri::XML(File.open(path))
      end


      def set_node(node, value)
        @ar.at_css(node).content = value
      end

      # Set the nodes' contents according to the command
      def set_nodes_contents
        if @command != :create_certificate && @command != :get_bank_certificate
          set_node("CustomerId", @customer_id)
          set_node("Timestamp", Time.now.iso8601)
          set_node("Environment", @environment)
          set_node("SoftwareId", "Sepa Transfer Library version #{VERSION}")
          set_node("Command",
                 @command.to_s.split(/[\W_]/).map {|c| c.capitalize}.join)
        end

        case @command
        when :create_certificate
          set_node("tns|CustomerId", @customer_id)
          set_node("tns|KeyGeneratorType", @key_generator_type)
          set_node("tns|EncryptionCertPKCS10", Base64.encode64(@encryption_cert_pkcs10.to_der))
          set_node("tns|SigningCertPKCS10", Base64.encode64(@signing_cert_pkcs10.to_der))
          set_node("tns|Timestamp", Time.now.iso8601)
          set_node("tns|RequestId", @request_id)
          set_node("tns|Environment", @environment)
          set_node("tns|PIN", @pin)
        when :get_certificate
          set_node("Service", @service)
          set_node("Content", Base64.encode64(@csr.to_der))
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
        when :get_bank_certificate
          set_node("elem|BankRootCertificateSerialNo", @bank_root_cert_serial)
          set_node("elem|Timestamp", Time.now.iso8601)
          set_node("elem|RequestId", @request_id)
        end
      end

      def create_hmac_seal(pin, csr)
        hmacseal = OpenSSL::HMAC.digest('sha1',pin,csr.to_der)
        hmacseal
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
