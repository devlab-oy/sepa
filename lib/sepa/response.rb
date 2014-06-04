module Sepa
  class Response
    include ActiveModel::Validations
    include Utilities

    attr_accessor :document

    validates :document, presence: true

    validate :check_validity_against_schema
    validate :validate_document_format

    def initialize(response)
      self.document = response
    end

    # Returns the x509 certificate embedded in the soap as an
    # OpenSSL::X509::Certificate
    def certificate
      cert_value = document.at(
        'wsse|BinarySecurityToken',
        'wsse' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-ws' \
        'security-secext-1.0.xsd'
      ).content.gsub(/\s+/, "")

      cert = process_cert_value(cert_value)

      begin
        cert = OpenSSL::X509::Certificate.new(cert)
      rescue => e
        fail OpenSSL::X509::CertificateError,
          "The certificate embedded to the soap response could not be process" \
          "ed. It's most likely corrupted. OpenSSL had this to say: #{e}."
          end
    end

    def danske_bank_encryption_cert
      cert = document.at(
        'BankEncryptionCert',
        'xmlns' => 'http://danskebank.dk/PKI/PKIFactoryService/elements'
      ).content.gsub(/\s+/, "")

      cert = process_cert_value(cert)

      begin
        cert = OpenSSL::X509::Certificate.new(cert)
      rescue => e
        fail OpenSSL::X509::CertificateError,
          "The certificate embedded to the soap response could not be process" \
          "ed. It's most likely corrupted. OpenSSL had this to say: #{e}."
          end
    end

    def danske_bank_signing_cert
      cert = document.at(
        'BankSigningCert',
        'xmlns' => 'http://danskebank.dk/PKI/PKIFactoryService/elements'
      ).content.gsub(/\s+/, "")

      cert = process_cert_value(cert)

      begin
        cert = OpenSSL::X509::Certificate.new(cert)
      rescue => e
        fail OpenSSL::X509::CertificateError,
          "The certificate embedded to the soap response could not be process" \
          "ed. It's most likely corrupted. OpenSSL had this to say: #{e}."
          end
    end

    def danske_bank_root_cert
      cert = document.at(
        'BankRootCert',
        'xmlns' => 'http://danskebank.dk/PKI/PKIFactoryService/elements'
      ).content.gsub(/\s+/, "")

      cert = process_cert_value(cert)

      begin
        cert = OpenSSL::X509::Certificate.new(cert)
      rescue => e
        fail OpenSSL::X509::CertificateError,
          "The certificate embedded to the soap response could not be process" \
          "ed. It's most likely corrupted. OpenSSL had this to say: #{e}."
          end
    end

    def own_encryption_cert
      cert = document.at(
        'EncryptionCert',
        'xmlns' => 'http://danskebank.dk/PKI/PKIFactoryService/elements'
      ).content.gsub(/\s+/, "")

      cert = process_cert_value(cert)

      begin
        cert = OpenSSL::X509::Certificate.new(cert)
      rescue => e
        fail OpenSSL::X509::CertificateError,
          "The certificate embedded to the soap document could not be process" \
          "ed. It's most likely corrupted. OpenSSL had this to say: #{e}."
          end
    end

    def own_signing_cert
      cert = document.at(
        'SigningCert',
        'xmlns' => 'http://danskebank.dk/PKI/PKIFactoryService/elements'
      ).content.gsub(/\s+/, "")

      cert = process_cert_value(cert)

      begin
        cert = OpenSSL::X509::Certificate.new(cert)
      rescue => e
        fail OpenSSL::X509::CertificateError,
          "The certificate embedded to the soap response could not be process" \
          "ed. It's most likely corrupted. OpenSSL had this to say: #{e}."
          end
    end

    # Verifies that the soap's certificate is trusted.
    def cert_is_trusted?(root_cert)
      if root_cert.subject == certificate.issuer
        certificate.verify(root_cert.public_key)
      else
        fail SecurityError,
          "The issuer of the certificate doesn't match the subject of the roo" \
          "t certificate."
      end
    end

    # Verifies that all digest values in the response match the actual ones.
    # Takes an optional verbose parameter to show which digests didn't match
    # i.e. verbose: true
    def hashes_match?(options = {})
      digests = find_digest_values(document)
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
      def find_digest_values(doc)
        references = {}
        reference_nodes = response.css(
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

      # Checks that the response is valid against soap schema.
      def check_validity_against_schema
        return false unless document.respond_to?(:canonicalize)
        schemas_path = File.expand_path(SCHEMA_PATH, __FILE__)
        Dir.chdir(schemas_path) do
          xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
          errors.add(:base, 'Document must validate against the schema file') \
          unless xsd.valid?(document)
        end
      end

      def validate_document_format
        errors.add(:base, 'Document must be a Nokogiri XML file') \
          unless document.respond_to?(:canonicalize)
      end
  end
end
