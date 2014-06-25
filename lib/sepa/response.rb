module Sepa
  class Response
    include ActiveModel::Validations
    include Utilities

    attr_reader :soap, :error, :command

    validates :soap, presence: true
    validate :validate_document_format
    validate :document_must_validate_against_schema
    validate :client_errors

    def initialize(hash = {})
      @soap = hash[:response]
      @command = hash[:command]
      @error = hash[:error]
    end

    def doc
      @doc ||= Nokogiri::XML @soap
    end

    # Verifies that all digest values in the response match the actual ones.
    # Takes an optional verbose parameter to show which digests didn't match
    # i.e. verbose: true
    def hashes_match?(options = {})
      digests = find_digest_values
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
        puts "These digests failed to verify: #{unverified_digests}."
      end

      false
    end

    # Verifies the signature by extracting the public key from the certificate
    # embedded in the soap header and verifying the signature value with that.
    def signature_is_valid?
      node = doc.at_css('xmlns|SignedInfo', 'xmlns' => 'http://www.w3.org/2000/09/xmldsig#')

      node = node.canonicalize(
        mode = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
        inclusive_namespaces = nil, with_comments = false
      )

      signature = doc.at_css(
        'xmlns|SignatureValue',
        'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
      ).content

      signature = Base64.decode64(signature)

      certificate.public_key.verify(OpenSSL::Digest::SHA1.new, signature, node)
    end

    # Gets the application response from the response as an xml document
    def application_response
      @application_response ||= extract_application_response('http://model.bxd.fi')
    end

    def file_references
      return unless @command == :download_file_list

      @file_references ||= begin
        xml = Nokogiri::XML content
        descriptors = xml.css('FileDescriptor')
        descriptors.map { |descriptor| descriptor.at('FileReference').content }
      end
    end

    def certificate
      @certificate ||= begin
        xsd = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'
        extract_cert(doc, 'BinarySecurityToken', xsd)
      end
    end

    def content
      @content ||= begin
        xml = Nokogiri::XML(application_response)
        xmlns = 'http://bxd.fi/xmldata/'

        case @command
        when :download_file
          content_node = xml.at('xmlns|Content', xmlns: xmlns)
          content_node.content if content_node
        when :download_file_list
          content_node = xml.remove_namespaces!.at('FileDescriptors')
          content_node.to_xml if content_node
        when :get_user_info
          canonicalized_node(xml, xmlns, 'UserFileTypes')
        when :upload_file
          signature_node = xml.at('xmlns|Signature', xmlns: 'http://www.w3.org/2000/09/xmldsig#')
          if signature_node
            signature_node.remove
            xml.canonicalize
          end
        end
      end
    end

    def to_s
      @soap
    end

    private

      # Finds all reference nodes with digest values in the document and returns
      # a hash with uri as the key and digest as the value.
      def find_digest_values
        references = {}
        reference_nodes = doc.css(
          'xmlns|Reference',
          'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
        )

        reference_nodes.each do |node|
          uri = node.attr('URI')
          digest_value = node.at_css(
            'xmlns|DigestValue',
            'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
          ).content

          references[uri] = digest_value
        end

        references
      end

      # Finds nodes to verify by comparing their id's to the uris' in the
      # references hash.
      def find_nodes_to_verify(references)
        nodes = {}

        references.each do |uri, digest_value|
          uri = uri.sub(/^#/, '')
          wsu = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'

          node = doc.at_css(
            "[wsu|Id='#{uri}']",
            'wsu' => wsu
          )

          nodes[uri] = calculate_digest(node)
        end

        nodes
      end

      def validate_document_format
        unless doc.respond_to?(:canonicalize)
          errors.add(:base, 'Document must be a Nokogiri XML file')
        end
      end

      def document_must_validate_against_schema
        check_validity_against_schema(doc, 'soap.xsd')
      end

      def extract_application_response(namespace)
        ar_node = doc.at_css('xmlns|ApplicationResponse', xmlns: namespace)
        Base64.decode64(ar_node.content)
      end

      def client_errors
        client_error = error.to_s
        errors.add(:base, client_error) unless client_error.empty?
      end

  end
end
