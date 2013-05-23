module Sepa
  class ApplicationRequest
    def initialize(params)
      @private_key = OpenSSL::PKey::RSA.new File.read params[:private_key]
      @cert = OpenSSL::X509::Certificate.new File.read params[:cert]
      @command = params[:command]
      @customer_id = params[:customer_id]
      @environment = params[:environment]
      @status = params[:status]
      @target_id = params[:target_id]
      @file_type = params[:file_type]
      @content = params[:content]
      @file_reference = params[:file_reference]
    end

    # Returns the application request in base64 encoded format
    def get_as_base64
      ar = sign
      Base64.encode64(ar.to_xml)
    end

    def get_as_xml
      sign.to_xml
    end

    # Loads the application request template according to the command
    def load_template(command)
      template_dir = File.expand_path('../xml_templates/application_request', __FILE__)

      case command
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

      begin
        @ar = Nokogiri::XML(File.open(path))
      rescue Errno::ENOENT => e
        raise e, "Could not load application request template for some reason. This might indicate
        a problem with you gem installation."
      end
    end

    def set_customer_id(customer_id)
      customer_id = @ar.at_css "CustomerId"
      customer_id.content = @customer_id
    end

    def set_timestamp
      timestamp = @ar.at_css "Timestamp"
      timestamp.content = Time.now.iso8601
    end

    def set_environment
      environment = @ar.at_css "Environment"
      environment.content = @environment
    end

    def set_software_id
      softwareid = @ar.at_css "SoftwareId"
      softwareid.content = "Sepa Transfer Library version " + VERSION
    end

    def set_command(command)
      command_node = @ar.at_css "Command"
      command_node.content = command.to_s.split(/[\W_]/).map {|c| c.capitalize}.join
    end

    def set_status(status)
      status_node = @ar.at_css "Status"
      status_node.content = status
    end

    def set_target_id(target_id)
      target_id_node = @ar.at_css "TargetId"
      target_id_node.content = target_id
    end

    def set_file_type(file_type)
      file_type_node = @ar.at_css "FileType"
      file_type_node.content = file_type
    end

    def set_content(content)
      content_node = @ar.at_css "Content"
      content_node.content = Base64.encode64(content)
    end

    def set_file_reference(file_reference)
      file_reference_node = @ar.at_css "FileReference"
      file_reference_node.content = file_reference
    end

    def set_nodes_contents
      load_template(@command)
      set_customer_id(@customer_id)
      set_timestamp
      set_environment
      set_software_id
      set_command(@command)

      case @command
      when :download_file_list
        set_status(@status)
        set_target_id(@target_id)
        set_file_type(@file_type)
      when :download_file
        set_status(@status)
        set_target_id(@target_id)
        set_file_type(@file_type)
        set_file_reference(@file_reference)
      when :upload_file
        set_content(@content)
        set_file_type(@file_type)
        set_target_id(@target_id)
      end
    end

    #Remove signature element from application request for hashing
    def remove_signature
      @ar.xpath("//dsig:Signature", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').remove
    end

    # Sign the whole application request using enveloped signature
    def sign
      set_nodes_contents
      signature = @ar.xpath("//dsig:Signature", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#')
      remove_signature

      #Take digest from application request
      sha1 = OpenSSL::Digest::SHA1.new
      digestbin = sha1.digest(@ar.canonicalize(mode=Nokogiri::XML::XML_C14N_1_0,inclusive_namespaces=nil,with_comments=false))
      digest = Base64.encode64(digestbin)

      # Add the signature
      @ar.root.add_child(signature)

      # Insert digest to correct place
      ar_digest = @ar.xpath(".//dsig:DigestValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
      ar_digest.content = digest.gsub(/\s+/, "")

      # Sign Signed info element
      signed_info = @ar.xpath(".//dsig:SignedInfo", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
      signed_info_canon = signed_info.canonicalize(mode=Nokogiri::XML::XML_C14N_1_0,inclusive_namespaces=nil,with_comments=false)
      digest_sign = OpenSSL::Digest::SHA1.new
      signed_info_signature = @private_key.sign(digest_sign, signed_info_canon)
      signature_base64 = Base64.encode64(signed_info_signature)

      #Add the base64 coded signature to the signature element
      signature_node = @ar.xpath(".//dsig:SignatureValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
      signature_node.content = signature_base64.gsub(/\s+/, "")

      #Format the certificate and add the it to the certificate element
      cert_formatted = @cert.to_s.split('-----BEGIN CERTIFICATE-----')[1].split('-----END CERTIFICATE-----')[0].gsub(/\s+/, "")
      cert_node = @ar.xpath(".//dsig:X509Certificate", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
      cert_node.content = cert_formatted

      @ar
    end
  end
end