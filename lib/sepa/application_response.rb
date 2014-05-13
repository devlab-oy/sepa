module Sepa
  class ApplicationResponse
    include ActiveModel::Validations

    attr_accessor :ar

    validate :check_validity_against_schema
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

      def calculate_digest(node)
        sha1 = OpenSSL::Digest::SHA1.new

        canon_node = node.canonicalize(
          mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
          inclusive_namespaces=nil,with_comments=false
        )

        Base64.encode64(sha1.digest(canon_node)).gsub(/\s+/, "")
      end

      def check_validity_against_schema
        return false unless ar.respond_to?(:canonicalize)
        schemas_path = File.expand_path(SCHEMA_PATH,
                                        __FILE__)

        Dir.chdir(schemas_path) do
          xsd = Nokogiri::XML::Schema(IO.read('application_response.xsd'))
          errors.add(:base, 'Application response must validate against the schema file') \
          unless xsd.valid?(ar)
        end
      end

      def validate_document_format
        errors.add(:base, 'Document must be a Nokogiri XML file') \
          unless ar.respond_to?(:canonicalize)
      end

      # Takes the certificate from the application response, adds begin and end
      # certificate texts and splits it into multiple lines so that OpenSSL
      # can read it.
      def process_cert_value(cert_value)
        cert = "-----BEGIN CERTIFICATE-----\n"
        cert += cert_value.to_s.gsub(/\s+/, "").scan(/.{1,64}/).join("\n")
        cert += "\n"
        cert += "-----END CERTIFICATE-----"
      end
  end
end
