module Sepa
  class ApplicationResponse
    include ActiveModel::Validations
    include Utilities

    attr_reader :application_response

    validate :response_must_validate_against_schema
    validate :validate_document_format

    def initialize(app_resp)
      @application_response = app_resp
    end

    # Checks that the hash value reported in the signature matches the actual one.
    def hashes_match?
      are = application_response.clone

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
      xmlns = 'http://www.w3.org/2000/09/xmldsig#'
      node = application_response.at_css('xmlns|SignedInfo', 'xmlns' => xmlns)
      node = node.canonicalize

      signature = application_response.at_css(
        'xmlns|SignatureValue',
        'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
      ).content

      signature = Base64.decode64(signature)

      # Return true or false
      certificate.public_key.verify(OpenSSL::Digest::SHA1.new, signature, node)
    end

    def certificate
      extract_cert(application_response, 'X509Certificate', 'http://www.w3.org/2000/09/xmldsig#')
    end

    private

      def validate_document_format
        unless application_response.respond_to?(:canonicalize)
          errors.add(:base, 'Document must be a Nokogiri XML file')
        end
      end

      def response_must_validate_against_schema
        check_validity_against_schema(application_response, 'application_response.xsd')
      end

  end
end
