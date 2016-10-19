module Sepa
  # Contains functionality to build the application request
  #
  # @todo Add return values for content modifying methods to signal whether they succeeded or not
  class ApplicationRequest
    include Utilities

    # Initializes the {ApplicationRequest} with a params hash. The application request is usually
    # initialized by the {SoapBuilder}. The xml template of the application request is also loaded
    # here.
    #
    # @param params [Hash] the hash containing attributes needed by the {ApplicationRequest}. All
    #   the key => value pairs in the hash are initialized as instance variables. The hash in the
    #   initialization is usually the same as with {SoapBuilder} so the values have already been
    #   validated by the client.
    # @todo Consider not using instance_variable_set so that all the available instance variables
    #   can easily be seen.
    def initialize(params = {})
      # Set all params as instance variables
      params.each do |key, value|
        instance_variable_set("@#{key}", value)
      end

      @application_request = load_body_template(AR_TEMPLATE_PATH)
    end

    # Sets the nodes in the application request, processes signature and then returns the
    # application request as an xml document.
    #
    # @return [String] the application request as an xml document
    # @todo This method is obviously doing too much
    def to_xml
      set_common_nodes
      set_nodes_contents
      process_signature
      @application_request.to_xml
    end

    # Base64 encodes the whole application request
    #
    # @return [String] the base64 encoded application request
    def to_base64
      encode to_xml
    end

    # Returns the application request as a Nokogiri document
    #
    # @return [Nokogiri::XML::Document] the application request as a nokogiri document
    def to_nokogiri
      Nokogiri::XML to_xml
    end

    private

      # Sets node to value
      #
      # @param node [String] the name of the node which value is to be set
      # @param value [#to_s] the value which is going to be set to the node
      def set_node(node, value)
        @application_request.at_css(node).content = value
      end

      # Sets node to base64 encoded value
      #
      # @param node [String] name of the node
      # @param value [#to_s] the value which is going to be set to the nodea base64 encoded
      # @todo rename
      def set_node_b(node, value)
        set_node node, encode(value)
      end

      # Converts {#command} to string, removes underscores and capitalizes it.
      #
      # @example Example input and output
      #   :get_user_info --> GetUserInfo
      def pretty_command
        @command.to_s.split(/[\W_]/).map(&:capitalize).join
      end

      # Determines which content setting method to call depending on {#command}
      def set_nodes_contents
        method = "set_#{@command}_nodes"

        send(method) if self.class.private_method_defined? method
      end

      # Sets nodes' values for download file request
      def set_download_file_nodes
        add_node_after('FileReferences', 'TargetId', content: @target_id) if @bank == :nordea
        add_node_after('Timestamp', 'Status', content: @status) if @status.present?
        add_node_to_root 'FileType', content: @file_type if @file_type.present?
        set_node("FileReference", @file_reference)
      end

      # Sets Danske Bank's get bank certificate request's contents
      #
      # @raise [OnlyWorksWithDanske] if {#bank} is not danske
      # @todo Investigate a better way to set the bank's root certificate's serial instead of
      #   hardcoding it
      def set_get_bank_certificate_nodes
        raise 'OnlyWorksWithDanske' if @bank != :danske

        # Root Cert Serial Hardcoded to Danske
        set_node("elem|BankRootCertificateSerialNo", '1111110002')
        set_node("elem|Timestamp", iso_time)
        set_node("elem|RequestId", @request_id)
      end

      # Sets nodes' contents for upload file request
      def set_upload_file_nodes
        set_node_b("Content", @content)
        set_node("FileType", @file_type)
        add_node_after('Environment', 'TargetId', content: @target_id) if @bank == :nordea
      end

      # Sets nodes' contents for download file list request
      def set_download_file_list_nodes
        add_node_after('Environment', 'TargetId', content: @target_id) if @bank == :nordea
        add_node_after('Timestamp', 'Status', content: @status) if @status.present?
        add_node_to_root 'FileType', content: @file_type if @file_type.present?
      end

      # Sets nodes' contents for Nordea's and OP's get certificate request
      def set_get_certificate_nodes
        set_node "Service", "MATU" if @bank == :op
        set_node "TransferKey", @pin if [:op, :samlink].include?(@bank)
        set_node "HMAC", hmac(@pin, csr_to_binary(@signing_csr)) if @bank == :nordea
        set_node "Content", format_cert_request(@signing_csr)
      end

      # Sets nodes' contents for renew certificate request
      def set_renew_certificate_nodes
        case @bank
        when :nordea, :op, :samlink
          set_node "Service", "service" if @bank == :nordea
          set_node "Content", format_cert_request(@signing_csr)
        when :danske
          @environment = 'customertest' if @environment == :test

          set_node 'tns|CustomerId',           @customer_id
          set_node 'tns|EncryptionCertPKCS10', format_cert_request(@encryption_csr)
          set_node 'tns|SigningCertPKCS10',    format_cert_request(@signing_csr)
          set_node 'tns|Timestamp',            iso_time
          set_node 'tns|Environment',          @environment
        end
      end

      # Sets nodes' contents for OP's get service certificates request
      def set_service_certificates_nodes
        set_node("Service", "MATU")
      end

      # Sets nodes' contents for Danske Bank's create certificate request. Environment is set to
      # customertest if {#environment} is `:test`
      #
      # @todo Raise error if {#bank} is other than Nordea like in {#set_get_bank_certificate_nodes}
      def set_create_certificate_nodes
        set_node("tns|CustomerId", @customer_id)
        set_node("tns|KeyGeneratorType", 'software')
        set_node("tns|EncryptionCertPKCS10", format_cert_request(@encryption_csr))
        set_node("tns|SigningCertPKCS10", format_cert_request(@signing_csr))
        set_node("tns|Timestamp", iso_time)
        set_node("tns|RequestId", @request_id)

        @environment = 'customertest' if @environment == :test
        set_node("tns|Environment", @environment)

        set_node("tns|PIN", @pin)
      end

      # Sets contents for nodes that are common to all requests except when {#command} is
      # `:get_bank_certificate` or `:create_certificate`. {#environment} is upcased here.
      def set_common_nodes
        return if [:get_bank_certificate, :create_certificate].include?(@command)
        return if @bank == :danske && @command == :renew_certificate

        set_node('Environment', @environment.to_s.upcase)
        set_node("CustomerId", @customer_id)
        set_node("Timestamp", iso_time)
        set_node("SoftwareId", "Sepa Transfer Library version #{VERSION}")
        set_node("Command", pretty_command) unless @command == :renew_certificate
      end

      # Removes a node from {#application_request}
      #
      # @param node [String] name of the node to remove
      # @param xmlns [String] the namespace of the node
      # @todo Move to {Utilities} and move document to parameters
      def remove_node(node, xmlns)
        @application_request.at_css("xmlns|#{node}", 'xmlns' => xmlns).remove
      end

      # Adds node to the root of the application request and content to it if specified
      def add_node_to_root(node, content: nil)
        unless node.is_a? Nokogiri::XML::Node
          node = Nokogiri::XML::Node.new node, @application_request
        end

        @application_request.root.add_child node

        set_node(node.name, content) if content
      end

      # Calculates the digest of {#application_request}
      #
      # @todo Use the digest calculation method in {Utilities} instead of implementing the
      #   functionality again here.
      # @return [String] the base64 encoded digest of the {#application_request}
      def calculate_digest
        sha1 = OpenSSL::Digest::SHA1.new
        encode(sha1.digest(@application_request.canonicalize(canonicalization_mode)))
      end

      # Adds value to signature node
      #
      # @param node [String] name of the signature node
      # @param value [#to_s] the value to be set to the node
      # @todo Remove this method and use {#set_node} method
      def add_value_to_signature(node, value)
        dsig = 'http://www.w3.org/2000/09/xmldsig#'
        sig = @application_request.at_css("dsig|#{node}", 'dsig' => dsig)
        sig.content = value
      end

      # Calculates the application request's signature value. Uses {#signing_private_key} for the
      # calculation.
      #
      # @return [String] the base64 encoded signature
      # @todo Move to {Utilities}
      def calculate_signature
        sha1 = OpenSSL::Digest::SHA1.new
        dsig = 'http://www.w3.org/2000/09/xmldsig#'
        node = @application_request.at_css("dsig|SignedInfo", 'dsig' => dsig)
        signature = @signing_private_key.sign(sha1, node.canonicalize(canonicalization_mode))
        encode signature
      end

      # Removes signature from the application request, calculates the application request's digest,
      # calculates the signature and adds needed values to signature node. Also adds
      # {#own_signing_certificate} to the signature node.
      def process_signature
        # No signature for Certificate Requests
        return if %i(
          create_certificate
          get_bank_certificate
          get_certificate
          get_service_certificates
        ).include? @command

        signature_node = remove_node('Signature', 'http://www.w3.org/2000/09/xmldsig#')
        digest = calculate_digest
        add_node_to_root(signature_node)
        add_value_to_signature('DigestValue', digest)
        add_value_to_signature('SignatureValue', calculate_signature)
        add_value_to_signature('X509Certificate', format_cert(@own_signing_certificate))
      end

      def add_node_after(node, new_node, content:)
        new_node = Nokogiri::XML::Node.new(new_node, @application_request)
        new_node.content = content
        @application_request.at(node).add_next_sibling(new_node)
      end

      def canonicalization_mode
        return Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0 if @bank == :danske && @command == :renew_certificate

        Nokogiri::XML::XML_C14N_1_0
      end
  end
end
