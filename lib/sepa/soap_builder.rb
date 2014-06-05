module Sepa
  class SoapBuilder
    include Utilities

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
      @header_template = load_header_template
      @template = load_body_template
      @ar = ApplicationRequest.new(params).get_as_base64

      find_correct_bank_extension
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
          mode = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
          inclusive_namespaces = nil, with_comments = false
        )

        Base64.encode64(sha1.digest(canon_node)).gsub(/\s+/, "")
      end

      def calculate_signature(doc, node)
        sha1 = OpenSSL::Digest::SHA1.new
        node = doc.at_css(node)

        canon_signed_info_node = node.canonicalize(
          mode = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
          inclusive_namespaces = nil, with_comments = false
        )

        signature = @private_key.sign(sha1, canon_signed_info_node)
        Base64.encode64(signature).gsub(/\s+/, "")
      end

      def load_header_template
        header_template = File.open("#{SOAP_TEMPLATE_PATH}/header.xml")
        Nokogiri::XML(header_template)
      end

      def load_body_template
        path = "#{SOAP_TEMPLATE_PATH}/"

        case @command
        when :download_file_list
          path << "download_file_list.xml"
        when :get_user_info
          path << "get_user_info.xml"
        when :upload_file
          path << "upload_file.xml"
        when :download_file
          path << "download_file.xml"
        when :get_certificate
          path << "get_certificate.xml"
        when :get_bank_certificate
          path << "danske_get_bank_certificate.xml"
        when :create_certificate
          path << "create_certificate.xml"
        else
          fail ArgumentError
        end

        Nokogiri::XML(File.open(path))
      end

      def set_node(doc, node, value)
        doc.at_css(node).content = value
      end

      def add_body_to_header
        body = @template.at_css('env|Body')
        @header_template.root.add_child(body)
        @header_template
      end

      def process_header
        set_node(@header_template, 'wsu|Created', Time.now.utc.iso8601)
        set_node(@header_template, 'wsu|Expires', (Time.now.utc + 300).iso8601)

        timestamp_digest = calculate_digest(@header_template,'wsu|Timestamp')
        dsig = 'dsig|Reference[URI="#dsfg8sdg87dsf678g6dsg6ds7fg"] dsig|DigestValue'
        set_node(@header_template, dsig, timestamp_digest)

        body_digest = calculate_digest(@template, 'env|Body')
        dsig = 'dsig|Reference[URI="#sdf6sa7d86f87s6df786sd87f6s8fsda"] dsig|DigestValue'
        set_node(@header_template, dsig, body_digest)

        signature = calculate_signature(@header_template, 'dsig|SignedInfo')
        set_node(@header_template, 'dsig|SignatureValue', signature)

        formatted_cert = format_cert(@cert)
        set_node(@header_template, 'wsse|BinarySecurityToken', formatted_cert)
      end

      def request_id
        SecureRandom.hex(5)
      end

  end
end
