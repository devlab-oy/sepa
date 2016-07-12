module Sepa
  # Handles soap responses got back from the bank. Bank specific functionality is defined in
  # subclasses. Handles i.e. logic to make sure the response's integrity has not been compromised
  # and has methods to extract content from the response.
  class Response
    include ActiveModel::Validations
    include Utilities
    include ErrorMessages

    # The raw soap response in xml
    #
    # @return [String]
    attr_reader :soap

    # Possible Savon::Error with which the {Response} was initialized
    #
    # @return [String]
    attr_reader :error

    # The command with which the response was initialized
    #
    # @return [Symbol]
    attr_reader :command

    # The environment in which the request was sent
    #
    # @return [Symbol]
    attr_reader :environment

    validate  :document_must_validate_against_schema
    validate  :client_errors
    validate  :validate_response_code
    validate  :validate_hashes
    validate  :verify_signature
    validate  :verify_certificate

    # Initializes the response with a options hash
    #
    # @param hash [Hash] Hash of options
    # @example Possible keys in options hash
    #   {
    #     response: "something",
    #     command: :get_user_info,
    #     error: "I'm error",
    #     encryption_private_key: OpenSSL::PKey::RSA
    #   }
    def initialize(hash = {})
      @command                = hash[:command]
      @encryption_private_key = hash[:encryption_private_key]
      @environment            = hash[:environment]
      @error                  = hash[:error]
      @soap                   = hash[:response]
    end

    # Returns the soap of the response as a Nokogiri document
    #
    # @return [Nokogiri::XML] The soap as Nokogiri document
    def doc
      @doc ||= xml_doc @soap
    end

    # Returns the error of the response as a Nokogiri document
    #
    # @return [Nokogiri::XML] The error as Nokogiri document
    def error_doc
      @error_doc ||= xml_doc @error
    end

    # Verifies that all digest values in the response match the actual ones. Takes an optional
    # verbose parameter to show which digests didn't match. The digest embedded in the document are
    # first retrieved with {#find_digest_values} method and if none are found, false is returned.
    # After this, nodes to calculate hashes from are retrieved and hashes using
    # {#find_nodes_to_verify} method and after this the calculated digests are compared with the
    # embedded ones. If the all match, true is returned. If some digests failed to verify and
    # verbose parameter was passed, digests that failed to verify are printed to screen and
    # false is returned. Otherwise just false is returned.
    #
    # @param options [Hash]
    # @return [false] if hashes don't match or aren't found
    # @return [true] if hashes match
    # @example Options hash
    #   { verbose: true }
    def hashes_match?(options = {})
      digests = find_digest_values

      return false if digests.empty?

      nodes = find_nodes_to_verify(digests)

      verified_digests = digests.select do |uri, digest|
        uri = uri.sub(/^#/, '')
        digest == nodes[uri]
      end

      return true if digests == verified_digests

      unverified_digests = digests.select do |uri, digest|
        uri = uri.sub(/^#/, '')
        digest != nodes[uri]
      end

      if options[:verbose]
        puts "These digests failed to verify: #{unverified_digests}"
      end

      false
    end

    # Verifies the signature by extracting the public key from the certificate embedded in the
    # response and verifying the signature value with that. Makes a call to {#validate_signature}
    # to do the actual verification. Passes `:exclusive` to {#validate_signature} so that exclusive
    # mode of xml canonicalization is used.
    #
    # @return [true] if signature is valid
    # @return [false] if signature fails to verify
    def signature_is_valid?
      validate_signature(doc, certificate, :exclusive)
    end

    # Gets the application response from the response as an xml document. Makes a call to
    # {#extract_application_response} to do the extraction.
    #
    # @return [String] The application response as a raw xml document
    def application_response
      @application_response ||= extract_application_response(BXD)
    end

    # Returns the file references in a download file list response
    #
    # @return [Array] File references
    def file_references
      return unless @command == :download_file_list

      @file_references ||= begin
        xml = xml_doc content
        descriptors = xml.css('FileDescriptor')
        descriptors.map { |descriptor| descriptor.at('FileReference').content }
      end
    end

    # Returns the certificate embedded in the response
    #
    # @return [OpenSSL::X509::Certificate] if the certificate is found
    # @return [nil] if the certificate can't be found
    # @raise [OpenSSL::X509::CertificateError] if the certificate cannot be processed
    def certificate
      @certificate ||= begin
        extract_cert(doc, 'BinarySecurityToken', OASIS_SECEXT)
      end
    end

    # Returns the content of the response according to {#command}. When command is `:download_file`,
    # content is returned as a base64 encoded string, when {#command} is `:download_file_list`, the
    # content is returned as xml, when {#command} is `:get_user_info`, the content is returned as xml
    # and when {#command} is `:upload_file`, content is returned as xml
    #
    # @return [String] the content as xml or base64 encoded string
    def content
      @content ||= begin
        xml = xml_doc(application_response)

        case @command
        when :download_file
          content_node = xml.at('xmlns|Content', xmlns: XML_DATA)
          content_node.content if content_node
        when :download_file_list
          content_node = xml.remove_namespaces!.at('FileDescriptors')
          content_node.to_xml if content_node
        when :get_user_info
          canonicalized_node(xml, XML_DATA, 'UserFileTypes')
        when :upload_file
          signature_node = xml.at('xmlns|Signature', xmlns: DSIG)
          if signature_node
            signature_node.remove
            xml.canonicalize
          end
        end
      end
    end

    # Returns the raw soap as xml
    #
    # @return [String]
    def to_s
      @soap
    end

    # @abstract
    def bank_encryption_certificate; end

    # @abstract
    def bank_signing_certificate; end

    # @abstract
    def bank_root_certificate; end

    # @abstract
    def own_encryption_certificate; end

    # @abstract
    def own_signing_certificate; end

    # @abstract
    def ca_certificate; end

    # Returns the response code of the response
    #
    # @return [String] if the response code can be found
    # @return [nil] if the response code cannot be found
    def response_code
      node = doc.at('xmlns|ResponseCode', xmlns: BXD)
      node = error_doc.at('xmlns|ResponseCode', xmlns: BXD) unless node
      node.content if node
    end

    # Returns the response text of the response
    #
    # @return [String] if the response text can be found
    # @return [nil] if the response text cannot be found
    def response_text
      node = doc.at('xmlns|ResponseText', xmlns: BXD)
      node = error_doc.at('xmlns|ResponseText', xmlns: BXD) unless node
      node.content if node
    end

    private

      # Finds all reference nodes with digest values in the document and returns a hash with uri as
      # the key and digest as the value.
      #
      # @return [Hash] hash of digests with reference uri as the key
      def find_digest_values
        references = {}
        reference_nodes = doc.css('xmlns|Reference', xmlns: DSIG)

        reference_nodes.each do |node|
          uri = node.attr('URI')
          digest_value = node.at('xmlns|DigestValue', xmlns: DSIG).content

          references[uri] = digest_value
        end

        references
      end

      # Finds nodes to verify by comparing their id's to the uris' in the references hash. Then
      # calculates the hashes of those nodes and returns them in a hash
      #
      # @param references [Hash]
      # @return [Hash] hash of calculated digests with reference uri as the key
      def find_nodes_to_verify(references)
        nodes = {}

        references.each do |uri, _digest_value|
          uri = uri.sub(/^#/, '')
          node = find_node_by_uri(uri)

          nodes[uri] = calculate_digest(node)
        end

        nodes
      end

      # Validates the document against soap schema unless {#error} is present or command is
      # `:get_bank_certificate`
      def document_must_validate_against_schema
        return if @error || command.to_sym == :get_bank_certificate

        check_validity_against_schema(doc, 'soap.xsd')
      end

      # Extracts and returns application response from the response
      #
      # @return [String] application response as raw xml if it can be found
      # @return [nil] if application response cannot be found
      def extract_application_response(namespace)
        ar_node = doc.at('xmlns|ApplicationResponse', xmlns: namespace)

        return unless ar_node

        decode(ar_node.content)
      end

      # Handles errors that have been passed from client
      def client_errors
        client_error = error.to_s
        errors.add(:base, client_error) unless client_error.empty?
      end

      # Find node by it's reference URI in soap header
      #
      # @param uri [String] the node's URI
      # @return [Nokogiri::XML::Node]
      def find_node_by_uri(uri)
        doc.at("[xmlns|Id='#{uri}']", xmlns: OASIS_UTILITY)
      end

      # Validates response code in response. "00" and "24" are currently considered valid.
      def validate_response_code
        return if %w(00 24).include? response_code

        errors.add(:base, response_code: response_code, response_text: response_text)
      end

      # Validates hashes in the response. {#hashes_match?} must return true for validation to pass.
      # Is not run if {#error} is present or response code is not ok.
      def validate_hashes
        return if @error || !response_code_is_ok? || hashes_match?

        errors.add(:base, HASH_ERROR_MESSAGE)
      end

      # Validate signature in the response. Validation is not run if {#error} is present or response
      # is not ok.
      def verify_signature
        return if @error || !response_code_is_ok? || signature_is_valid?

        errors.add(:base, SIGNATURE_ERROR_MESSAGE)
      end

      # Validates certificate in the soap. The certificate must be present and signed by the bank's
      # root certificate for the validation to pass. Is not run if {#error} is present or response
      # code is not ok.
      def verify_certificate
        return if @error || !response_code_is_ok? || certificate_is_trusted?

        errors.add(:base, 'The certificate in the response is not trusted')
      end

      # Checks whether response code in the response is ok. Response code is considered ok if it is
      # "00" or "24".
      #
      # @return [true] if response code is ok
      # @return [false] if response code is not ok
      def response_code_is_ok?
        return true if %w(00 24).include? response_code

        false
      end
  end
end
