module Sepa
  class ApplicationResponse
    include ActiveModel::Validations
    include Utilities

    attr_accessor :ar

    validate :response_must_validate_against_schema
    validate :validate_document_format

    def initialize(app_resp)
      self.ar = app_resp
    end

    # Checks that the hash value reported in the signature matches the actual
    # one.
    def hashes_match?
      are = ar.clone

      digest_value = are.at_css(
        'xmlns|DigestValue',
        'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
      ).content.strip

      are.at_css(
        "xmlns|Signature",
        'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
      ).remove
      errors.add(:base, "#{are.inspect}")
      actual_digest = calculate_digest(are)

      if digest_value == actual_digest
        true
      else
        false
      end
    end

    # Extracts the X509 certificate from the application response.
    def certificate
      cert_value = ar.at_css(
        'xmlns|X509Certificate',
        'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
      ).content.gsub(/\s+/, "")

      cert = process_cert_value(cert_value)

      begin
        OpenSSL::X509::Certificate.new(cert)
      rescue => e
        fail OpenSSL::X509::CertificateError,
          "The certificate embedded in the application response could not be " \
          "processed. It's most likely corrupted. " \
          "OpenSSL had this to say: #{e}."
          end
    end

    # Checks that the signature is signed with the private key of the
    # certificate's public key.
    def signature_is_valid?
      node = ar.at_css('xmlns|SignedInfo',
                        'xmlns' => 'http://www.w3.org/2000/09/xmldsig#')

      node = node.canonicalize

      signature = ar.at_css(
        'xmlns|SignatureValue',
        'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
      ).content

      signature = Base64.decode64(signature)

      certificate.public_key.verify(OpenSSL::Digest::SHA1.new, signature, node)
    end

    # Checks that the certificate in the application response is signed with the
    # private key of the public key of the certificate as parameter.
    def cert_is_trusted?(root_cert)
      if root_cert.subject == certificate.issuer
        certificate.verify(root_cert.public_key)
      else
        fail SecurityError,
          "The issuer of the certificate doesn't match the subject of the " \
          "root certificate."
      end
    end

    private

      def validate_document_format
        errors.add(:base, 'Document must be a Nokogiri XML file') \
          unless ar.respond_to?(:canonicalize)
      end

      def response_must_validate_against_schema
        check_validity_against_schema(ar, 'application_response.xsd')
      end
  end
end
