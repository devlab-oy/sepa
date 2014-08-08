module Sepa

  # Builds a soap message with given parameters. This class is extended with proper bank module
  # depending on bank.
  class SoapBuilder
    include Utilities

    # Application request built with the same parameters as the soap
    #
    # @return [ApplicationRequest]
    attr_reader :application_request

    # Initializes the {SoapBuilder} with the params hash and then extends the {SoapBuilder} with the
    # correct bank module. The {SoapBuilder} class is usually created by the client which handles
    # parameter validation.
    #
    # @param params [Hash] options hash
    def initialize(params)
      @bank                        = params[:bank]
      @own_signing_certificate     = params[:own_signing_certificate]
      @command                     = params[:command]
      @content                     = params[:content]
      @customer_id                 = params[:customer_id]
      @bank_encryption_certificate = params[:bank_encryption_certificate]
      @environment                 = params[:environment]
      @file_reference              = params[:file_reference]
      @file_type                   = params[:file_type]
      @language                    = params[:language]
      @signing_private_key         = params[:signing_private_key]
      @status                      = params[:status]
      @target_id                   = params[:target_id]

      @application_request         = ApplicationRequest.new params
      @header_template             = load_header_template
      @template                    = load_body_template SOAP_TEMPLATE_PATH

      find_correct_bank_extension
    end

    # Returns the soap as raw xml
    #
    # @return [String] the soap as xml
    def to_xml
      find_correct_build.to_xml
    end

    private

      # Extends the class with proper module depending on bank
      def find_correct_bank_extension
        case @bank
        when :danske
          self.extend(DanskeSoapRequest)
        when :nordea
          self.extend(NordeaSoapRequest)
        end
      end

      # Calculates digest hash for the given node in the given document. The node is canonicalized
      # exclusively before digest calculation.
      #
      # @param doc [Nokogiri::XML] Document that contains the node
      # @param node [String] The name of the node
      # @return [String] the base64 encoded string
      # @todo remove this method and use {Utilities#calculate_digest}
      def calculate_digest(doc, node)
        sha1 = OpenSSL::Digest::SHA1.new
        node = doc.at_css(node)

        canon_node = node.canonicalize(
          mode = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
          inclusive_namespaces = nil, with_comments = false
        )

        encode(sha1.digest(canon_node)).gsub(/\s+/, "")
      end

      # Calculates signature for the given node in the given document. Uses the signing private key
      # given to SoapBuilder for the signing. The node is canonicalized exclusively before signature
      # calculation.
      #
      # @param doc [Nokogiri::XML] Document that contains the node
      # @param node [String] Name of the node to calculate signature from
      # @return [String] the base64 encoded signature
      # @todo refactor to use canonicalization from utilities
      def calculate_signature(doc, node)
        sha1 = OpenSSL::Digest::SHA1.new
        node = doc.at_css(node)

        canon_signed_info_node = node.canonicalize(
          mode = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
          inclusive_namespaces = nil, with_comments = false
        )

        signature = @signing_private_key.sign(sha1, canon_signed_info_node)
        encode(signature).gsub(/\s+/, "")
      end

      # Loads soap header template to be later populated
      #
      # @return [Nokogiri::XML] the header as Nokogiri document
      def load_header_template
        path = File.open("#{SOAP_TEMPLATE_PATH}/header.xml")
        Nokogiri::XML(path)
      end

      # Sets value to a node's content in the given document
      # @param doc [Nokogiri::XML] The document that contains the node
      # @param node [String] The name of the node which value is about to be set
      # @param value [#to_s] The value which will be set to the node
      def set_node(doc, node, value)
        doc.at_css(node).content = value
      end

      # Adds soap body to header template
      #
      # @return [Nokogiri::XML] the soap with added body as a nokogiri document
      def add_body_to_header
        body = @template.at_css('env|Body')
        @header_template.root.add_child(body)
        @header_template
      end

      # Add needed information to soap header. Mainly security related stuff. The process is as
      # follows:
      # 1. The reference id of the security token is set using {#set_token_id} method
      # 2. Created and expires timestamps are set. Expires is set to be 5 minutes after creation.
      # 3. Timestamp reference id is set with {#set_node_id} method
      # 4. The digest of timestamp node is calculated and set to correct node
      # 5. The reference id of body is set with {#set_node_id}
      # 6. The digest of body is calculated and set to correct node
      # 7. The signature of SignedInfo node is calculated and added to correct node
      # 8. Own signing certificate is formatted (Begin and end certificate removed and linebreaks
      #    removed) and embedded in the soap
      # @todo split into smaller methods
      def process_header
        set_token_id

        set_node(@header_template, 'wsu|Created', iso_time)
        set_node(@header_template, 'wsu|Expires', (Time.now.utc + 300).iso8601)

        timestamp_id = set_node_id(@header_template, OASIS_UTILITY, 'Timestamp', 0)

        timestamp_digest = calculate_digest(@header_template, 'wsu|Timestamp')
        dsig = "dsig|Reference[URI='##{timestamp_id}'] dsig|DigestValue"
        set_node(@header_template, dsig, timestamp_digest)

        body_id = set_node_id(@template, ENVELOPE, 'Body', 1)

        body_digest = calculate_digest(@template, 'env|Body')
        dsig = "dsig|Reference[URI='##{body_id}'] dsig|DigestValue"
        set_node(@header_template, dsig, body_digest)

        signature = calculate_signature(@header_template, 'dsig|SignedInfo')
        set_node(@header_template, 'dsig|SignatureValue', signature)

        formatted_cert = format_cert(@own_signing_certificate)
        set_node(@header_template, 'wsse|BinarySecurityToken', formatted_cert)
      end

      # Generates a random token id and sets it to correct node
      def set_token_id
        security_token_id = "token-#{SecureRandom.uuid}"

        @header_template.at('wsse|BinarySecurityToken')['wsu:Id'] = security_token_id
        @header_template.at('wsse|Reference')['URI'] = "##{security_token_id}"
      end

  end
end
