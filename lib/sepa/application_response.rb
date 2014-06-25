module Sepa
  class ApplicationResponse
    include ActiveModel::Validations
    include Utilities

    attr_accessor :xml

    validate :response_must_validate_against_schema
    validate :validate_document_format

    def initialize(app_resp)
      @xml = app_resp
    end

    def doc
      @doc ||= xml_doc @xml
    end

    def certificate
      @certificate ||= extract_cert(doc, 'X509Certificate', 'http://www.w3.org/2000/09/xmldsig#')
    end

    # Checks that the hash value reported in the signature matches the actual one.
    def hashes_match?
      are = doc.clone

      digest_value = are.at_css(
        'xmlns|DigestValue',
        'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
      ).content.strip

      are.at_css(
        "xmlns|Signature",
        'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
      ).remove

      actual_digest = calculate_digest(are)

      return true if digest_value == actual_digest

      false
    end

    # Checks that the signature is signed with the private key of the certificate's public key.
    def signature_is_valid?
      node = doc.at_css('xmlns|SignedInfo', 'xmlns' => 'http://www.w3.org/2000/09/xmldsig#')

      node = node.canonicalize

      signature = doc.at_css(
        'xmlns|SignatureValue',
        'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
      ).content

      signature = Base64.decode64(signature)

      # Return true or false
      certificate.public_key.verify(OpenSSL::Digest::SHA1.new, signature, node)
    end

    def to_s
      @xml
    end

    private

      def validate_document_format
        unless doc.respond_to?(:canonicalize)
          errors.add(:base, 'Document must be a valid XML file')
        end
      end

      def response_must_validate_against_schema
        check_validity_against_schema(doc, 'application_response.xsd')
      end

  end
end
