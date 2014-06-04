module Sepa
  class SoapBuilder
    # SoapBuilder creates the SOAP structure.
    def initialize(params)
      @bank = params[:bank]
      @private_key = params[:private_key]
      @cert = params[:cert]
      @command = params[:command]
      @customer_id = params[:customer_id]
      @environment = params[:environment]
      @status = params[:status]
      @target_id = params[:target_id]
      @language = params[:language]
      @file_type = params[:file_type]
      @content = params[:content]
      @file_reference = params[:file_reference]
      @enc_cert = params[:enc_cert]
      @request_id = request_id

      @ar = ApplicationRequest.new(params).get_as_base64

      find_correct_bank_extension

      @template_path = File.expand_path('../xml_templates/soap/', __FILE__)
    end

    def to_xml
      # Returns a complete SOAP message in xml format
      find_correct_build.to_xml
    end

    def get_ar_as_base64
      @ar
    end

    private


    def find_correct_bank_extension
      case @bank
      when :danske
        self.extend(DanskeSoapRequest)
      when :nordea
        self.extend(NordeaSoapRequest)
      end
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

    def calculate_signature(doc, node)
      sha1 = OpenSSL::Digest::SHA1.new

      node = doc.at_css(node)

      canon_signed_info_node = node.canonicalize(
        mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,inclusive_namespaces=nil,
        with_comments=false
      )

      signature = @private_key.sign(sha1, canon_signed_info_node)

      Base64.encode64(signature).gsub(/\s+/, "")
    end

    def load_body_template
      case @command
      when :download_file_list
        path = "#{@template_path}/download_file_list.xml"
      when :get_user_info
        path = "#{@template_path}/get_user_info.xml"
      when :upload_file
        path = "#{@template_path}/upload_file.xml"
      when :download_file
        path = "#{@template_path}/download_file.xml"
      when :get_certificate
        path = "#{@template_path}/get_certificate.xml"
      when :get_bank_certificate
        path = "#{@template_path}/danske_get_bank_certificate.xml"
      when :create_certificate
        path = "#{@template_path}/create_certificate.xml"
      end

      body_template = File.open(path)
      body = Nokogiri::XML(body_template)
      body_template.close

      body
    end

    def set_node(doc, node, value)
      doc.at_css(node).content = value
    end

    def add_body_to_header(header, body)
      body = body.at_css('env|Body')
      header.root.add_child(body)
      header
    end

    def format_cert(cert)
      cert = cert.to_s
      cert = cert.split('-----BEGIN CERTIFICATE-----')[1]
      cert = cert.split('-----END CERTIFICATE-----')[0]
      cert.gsub!(/\s+/, "")
    end

    def load_header_template(template_path)
      header_template = File.open("#{template_path}/header.xml")
      header = Nokogiri::XML(header_template)
      header_template.close
      header
    end

    def process_header(header, body)
      set_node(header, 'wsu|Created', Time.now.utc.iso8601)

      set_node(header, 'wsu|Expires', (Time.now.utc + 300).iso8601)

      timestamp_digest = calculate_digest(header,'wsu|Timestamp')
      set_node(header,'dsig|Reference[URI="#dsfg8sdg87dsf678g6dsg6ds7fg"]' \
               ' dsig|DigestValue', timestamp_digest)

      body_digest = calculate_digest(body, 'env|Body')
      set_node(header,'dsig|Reference[URI="#sdf6sa7d86f87s6df786sd87f6s8fsd'\
               'a"] dsig|DigestValue', body_digest)

      signature = calculate_signature(header, 'dsig|SignedInfo')
      set_node(header, 'dsig|SignatureValue', signature)

      formatted_cert = format_cert(@cert)
      set_node(header, 'wsse|BinarySecurityToken', formatted_cert)
    end

    def request_id
      SecureRandom.hex(5)
    end

  end
end
