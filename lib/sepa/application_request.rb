module Sepa
  class ApplicationRequest
    def initialize(params)
      @command = params.fetch(:command)
      @private_key = params.fetch(:private_key) unless @command == :get_certificate
      @cert = params.fetch(:cert) unless @command == :get_certificate
      @customer_id = params.fetch(:customer_id)
      @environment = params.fetch(:environment)
      @status = params[:status]
      @target_id = params[:target_id]
      @file_type = params[:file_type]
      @content = params[:content]
      @file_reference = params[:file_reference]
      @service = params[:service]
      @hmac = params[:hmac]
      @pin = params[:pin]
      @key_generator_type = params[:key_generator_type]
    end

    def get_as_base64
      load_template(@command)
      set_nodes_contents
      process_signature unless @command == :get_certificate || @command == :create_certificate
      Base64.encode64(@ar.to_xml)
    end

    private

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
      else
        raise ArgumentError, 'Could not load application request template because command was
        unrecognised.'
      end

      @ar = Nokogiri::XML(File.open(path))
    end

    def set_node(node, value)
      @ar.at_css(node).content = value
    end

    # Set the nodes' contents according to the command
    def set_nodes_contents
      set_node("CustomerId", @customer_id)
      set_node("Timestamp", Time.now.iso8601)
      set_node("Environment", @environment) unless @command == :create_certificate
      set_node("SoftwareId", "Sepa Transfer Library version #{VERSION}") unless @command == :create_certificate
      set_node("Command", @command.to_s.split(/[\W_]/).map {|c| c.capitalize}.join) unless @command == :create_certificate

      case @command

      when :create_certificate
        set_node("PIN", @pin)
        set_node("KeyGeneratorType", @key_generator_type)
        set_node("EncryptionCertPKCS10", @encryption_cert_pkcs10)
        set_node("SigningCertPKCS10", @signing_cert_pkcs10)
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

    def remove_signature_node(doc)
      doc.xpath(
      "//dsig:Signature", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
      ).remove
    end

    def add_signature_node(doc, signature)
      doc.root.add_child(signature)
    end

    def take_digest(doc)
      sha1 = OpenSSL::Digest::SHA1.new
      Base64.encode64(sha1.digest(doc.canonicalize))
    end

    def add_digest(doc, digest)
      doc.xpath(
      ".//dsig:DigestValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#'
      ).first
      .content = digest.gsub(/\s+/, "")
    end

    def calculate_signature(node, private_key)
      digest = OpenSSL::Digest::SHA1.new
      signature = private_key.sign(digest, node.canonicalize)
      Base64.encode64(signature).gsub(/\s+/, "")
    end

    def add_signature(doc, signature)
      signature_node = doc
      .xpath(".//dsig:SignatureValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#')
      .first
      signature_node.content = signature
    end

    def add_certificate(doc, cert)
      doc
      .xpath(".//dsig:X509Certificate", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#')
      .first
      .content = cert
      .to_s
      .split('-----BEGIN CERTIFICATE-----')[1]
      .split('-----END CERTIFICATE-----')[0]
      .gsub(/\s+/, "")
    end

    def process_signature
      signature_node = remove_signature_node(@ar)
      digest = take_digest(@ar)
      add_signature_node(@ar, signature_node)
      add_digest(@ar, digest)
      signature = calculate_signature(
      @ar.xpath(".//dsig:SignedInfo", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first,
      @private_key)
      add_signature(@ar, signature)
      add_certificate(@ar, @cert)
    end
  end
end