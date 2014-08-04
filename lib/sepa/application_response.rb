module Sepa
  class ApplicationResponse
    include ActiveModel::Validations
    include Utilities

    attr_reader :xml

    validate :response_must_validate_against_schema

    def initialize(app_resp)
      @xml = app_resp
    end

    def doc
      @doc ||= xml_doc @xml
    end

    # Checks that the hash value reported in the signature matches the actual one.
    def hashes_match?
      are = doc.clone

      digest_value = are.at('xmlns|DigestValue', xmlns: DSIG).content.strip

      are.at('xmlns|Signature', xmlns: DSIG).remove

      actual_digest = calculate_digest(are)

      return true if digest_value == actual_digest

      false
    end

    # Checks that the signature is signed with the private key of the certificate's public key.
    def signature_is_valid?
      node = doc.at('xmlns|SignedInfo', xmlns: DSIG)
      node = node.canonicalize

      signature = doc.at('xmlns|SignatureValue', xmlns: DSIG).content
      signature = decode(signature)

      # Return true or false
      certificate.public_key.verify(OpenSSL::Digest::SHA1.new, signature, node)
    end

    def to_s
      @xml
    end

    def certificate
      extract_cert(doc, 'X509Certificate', DSIG)
    end

    private

      def response_must_validate_against_schema
        check_validity_against_schema(doc, 'application_response.xsd')
      end

  end
end
