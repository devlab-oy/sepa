module Sepa
  class SoapBuilder
    include Utilities

    attr_reader :application_request

    # SoapBuilder creates the SOAP structure.
    def initialize(params)
      @bank                = params[:bank]
      @cert                = params[:cert]
      @command             = params[:command]
      @content             = params[:content]
      @customer_id         = params[:customer_id]
      @enc_cert            = params[:enc_cert]
      @environment         = params[:environment]
      @file_reference      = params[:file_reference]
      @file_type           = params[:file_type]
      @language            = params[:language]
      @private_key         = params[:private_key]
      @status              = params[:status]
      @target_id           = params[:target_id]

      @application_request = ApplicationRequest.new params
      @header_template     = load_header_template
      @template            = load_body_template SOAP_TEMPLATE_PATH

      find_correct_bank_extension
    end

    def to_xml
      # Returns a complete SOAP message in xml format
      find_correct_build.to_xml
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

        encode(sha1.digest(canon_node)).gsub(/\s+/, "")
      end

      def calculate_signature(doc, node)
        sha1 = OpenSSL::Digest::SHA1.new
        node = doc.at_css(node)

        canon_signed_info_node = node.canonicalize(
          mode = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
          inclusive_namespaces = nil, with_comments = false
        )

        signature = @private_key.sign(sha1, canon_signed_info_node)
        encode(signature).gsub(/\s+/, "")
      end

      def load_header_template
        path = File.open("#{SOAP_TEMPLATE_PATH}/header.xml")
        Nokogiri::XML(path)
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
        set_token_id

        set_node(@header_template, 'wsu|Created', iso_time)
        set_node(@header_template, 'wsu|Expires', (Time.now.utc + 300).iso8601)

        timestamp_id = set_timestamp_id

        timestamp_digest = calculate_digest(@header_template, 'wsu|Timestamp')
        dsig = "dsig|Reference[URI='##{timestamp_id}'] dsig|DigestValue"
        set_node(@header_template, dsig, timestamp_digest)

        body_digest = calculate_digest(@template, 'env|Body')
        dsig = 'dsig|Reference[URI="#sdf6sa7d86f87s6df786sd87f6s8fsda"] dsig|DigestValue'
        set_node(@header_template, dsig, body_digest)

        signature = calculate_signature(@header_template, 'dsig|SignedInfo')
        set_node(@header_template, 'dsig|SignatureValue', signature)

        formatted_cert = format_cert(@cert)
        set_node(@header_template, 'wsse|BinarySecurityToken', formatted_cert)
      end

      def set_token_id
        security_token_id = "token-#{SecureRandom.uuid}"

        @header_template.at('wsse|BinarySecurityToken')['wsu:Id'] = security_token_id
        @header_template.at('wsse|Reference')['URI'] = "##{security_token_id}"
      end

      def set_timestamp_id
        timestamp_id = "timestamp-#{SecureRandom.uuid}"

        @header_template.at('wsu|Timestamp')['wsu:Id'] = timestamp_id
        @header_template.css('dsig|Reference')[0]['URI'] = "##{timestamp_id}"

        timestamp_id
      end

  end
end
