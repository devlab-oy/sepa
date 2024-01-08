module Sepa
  # Contains functionality for the application response embedded in {Response}
  # @todo Use functionality from this class more when validating response
  class ApplicationResponse
    include ActiveModel::Validations
    include Utilities

    # The raw xml of the application response
    #
    # @return [String] the raw xml of the application response
    attr_reader :xml

    validate :response_must_validate_against_schema

    # Initializes the {ApplicationResponse} with an application response xml and bank
    #
    # @param app_resp [#to_s] the application response xml
    # @param bank [Symbol] the bank from which the application response came from
    def initialize(app_resp, bank)
      @xml = app_resp
      @bank = bank
    end

    # The application response as a nokogiri xml document
    #
    # @return [Nokogiri::XML::Document] the application response as a nokogiri document
    def doc
      @doc ||= xml_doc @xml
    end

    # Checks that the hash value reported in the signature matches the one that is calculated
    # locally
    #
    # @return [true] if hashes match
    # @return [false] if hashes don't match
    def hashes_match?
      are = doc.clone

      digest_value = are.at('xmlns|DigestValue', xmlns: DSIG).content.strip

      are.at('xmlns|Signature', xmlns: DSIG).remove

      
      actual_digest = calculate_digest(are, bank_digest_method)

      return true if digest_value == actual_digest

      false
    end

    # Checks that the signature has been calculated with the private key of the certificate's public
    # key.
    #
    # @return [true] if signature can be verified
    # @return [false] if signature fails to verify
    def signature_is_valid?
      validate_signature(doc, certificate, :normal)
    end

    # Returns the raw xml of the application response
    #
    # @return [String] the raw xml of the application response
    def to_s
      @xml
    end

    # The certificate which private key has been used to sign the application response
    #
    # @return [OpenSSL::X509::Certificate] if the certificate can be found
    # @return [nil] if the certificate cannot be found
    # @raise [OpenSSL::X509::CertificateError] if the certificate is not valid
    def certificate
      extract_cert(doc, 'X509Certificate', DSIG)
    end

    # Checks whether the embedded certificate has been signed by the private key of the bank's root
    # certificate. The root certificate used varies by bank.
    #
    # @return [true] if the certificate is trusted
    # @return [false] if the certificate is not trusted
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

    def bank_digest_method
      return :sha256 if @bank == :nordea

      return :sha1
    end

    private

      # Validates that the response is valid against the application response schema
      def response_must_validate_against_schema
        check_validity_against_schema(doc, 'application_response.xsd')
      end
  end
end
