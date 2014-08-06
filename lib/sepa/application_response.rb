module Sepa
  class ApplicationResponse
    include ActiveModel::Validations
    include Utilities

    attr_reader :xml

    validate :response_must_validate_against_schema

    def initialize(app_resp, bank)
      @xml = app_resp
      @bank = bank
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
      validate_signature(doc, certificate, :normal)
    end

    def to_s
      @xml
    end

    def certificate
      extract_cert(doc, 'X509Certificate', DSIG)
    end

    def certificate_is_trusted?
      root_certificate =
        case @bank
        when :nordea
          NORDEA_ROOT_CERTIFICATE
        when :danske
          DANSKE_ROOT_CERTIFICATE
        end

      verify_certificate_against_root_certificate(certificate, root_certificate)
    end

    private

      def response_must_validate_against_schema
        check_validity_against_schema(doc, 'application_response.xsd')
      end

  end
end
