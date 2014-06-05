module Sepa
  class Response
    include ActiveModel::Validations
    include Utilities

    attr_reader :document, :certificate, :danske_encryption_cert, :danske_bank_signing_cert,
                :danske_bank_root_cert, :own_encryption_cert, :own_signing_cert

    validates :document, presence: true
    validate :validate_document_format
    validate :document_must_validate_against_schema

    def initialize(response)
      @document = response
      @certificate = extract_cert(document, 'BinarySecurityToken', 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd')
      @danske_encryption_cert = extract_cert(document, 'BankEncryptionCert', 'http://danskebank.dk/PKI/PKIFactoryService/elements')
      @danske_bank_signing_cert = extract_cert(document, 'BankSigningCert', 'http://danskebank.dk/PKI/PKIFactoryService/elements')
      @danske_bank_root_cert = extract_cert(document, 'BankRootCert', 'http://danskebank.dk/PKI/PKIFactoryService/elements')
      @own_encryption_cert = extract_cert(document, 'EncryptionCert', 'http://danskebank.dk/PKI/PKIFactoryService/elements')
      @own_signing_cert = extract_cert(document, 'SigningCert', 'http://danskebank.dk/PKI/PKIFactoryService/elements')
    end

    # Verifies that the soap's certificate is trusted.
    def cert_is_trusted?(root_cert)
      if root_cert.subject == certificate.issuer
        certificate.verify(root_cert.public_key)
      else
        fail SecurityError,
          "The issuer of the certificate doesn't match the subject of the root certificate."
      end
    end

    # Verifies that all digest values in the response match the actual ones.
    # Takes an optional verbose parameter to show which digests didn't match
    # i.e. verbose: true
    def hashes_match?(options = {})
      digests = find_digest_values
      nodes = find_nodes_to_verify(document, digests)

      verified_digests = digests.select do |uri, digest|
        uri = uri.sub(/^#/, '')
        digest == nodes[uri]
      end

      if digests == verified_digests
        true
      else
        unverified_digests = digests.select do |uri, digest|
          uri = uri.sub(/^#/, '')
          digest != nodes[uri]
        end

        if options[:verbose]
          puts "These digests failed to verify: #{unverified_digests}."
        end

        false
      end
    end

    # Verifies the signature by extracting the public key from the certificate
    # embedded in the soap header and verifying the signature value with that.
    def signature_is_valid?
      node = document.at_css('xmlns|SignedInfo',
                              'xmlns' => 'http://www.w3.org/2000/09/xmldsig#')

      node = node.canonicalize(
        mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
        inclusive_namespaces=nil,with_comments=false
      )

      signature = document.at_css(
        'xmlns|SignatureValue',
        'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
      ).content

      signature = Base64.decode64(signature)


      certificate.public_key.verify(OpenSSL::Digest::SHA1.new, signature, node)
    end

    # Gets the application response from the response as an Nokogiri::XML
    # document
    def application_response
      ar = document.at_css('mod|ApplicationResponse').content
      ar = Base64.decode64(ar)
      Nokogiri::XML(ar)
    end

    private

      # Finds all reference nodes with digest values in the document and returns
      # a hash with uri as the key and digest as the value.
      def find_digest_values
        references = {}
        reference_nodes = document.css(
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
      def find_nodes_to_verify(doc, references)
        nodes = {}
        references.each do |uri, digest_value|
          uri = uri.sub(/^#/, '')
          node = doc.at_css(
            "[wsu|Id='" + uri + "']",
            'wsu' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss' \
            '-wssecurity-utility-1.0.xsd'
          )

          nodes[uri] = calculate_digest(node)
        end

        nodes
      end

      def validate_document_format
        errors.add(:base, 'Document must be a Nokogiri XML file') \
          unless document.respond_to?(:canonicalize)
      end

      def document_must_validate_against_schema
        check_validity_against_schema(document, 'soap.xsd')
      end
  end
end
