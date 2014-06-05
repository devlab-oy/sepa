module Sepa
  module Utilities
    def calculate_digest(node)
      sha1 = OpenSSL::Digest::SHA1.new

      canon_node = node.canonicalize(
          mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
          inclusive_namespaces=nil, with_comments=false
      )

      Base64.encode64(sha1.digest(canon_node)).gsub(/\s+/, "")
    end

    # Takes a certificate, adds begin and end
    # certificate texts and splits it into multiple lines so that OpenSSL
    # can read it.
    def process_cert_value(cert_value)
      cert = "-----BEGIN CERTIFICATE-----\n"
      cert += cert_value.to_s.gsub(/\s+/, "").scan(/.{1,64}/).join("\n")
      cert += "\n"
      cert + "-----END CERTIFICATE-----"
    end

    def check_validity_against_schema(doc, schema)
      return false unless doc.respond_to?(:canonicalize)
      schemas_path = File.expand_path(SCHEMA_PATH,
                                      __FILE__)

      Dir.chdir(schemas_path) do
        xsd = Nokogiri::XML::Schema(IO.read(schema))
        errors.add(:base, 'The document did not validate against the schema file') \
          unless xsd.valid?(doc)
      end
    end

    # Extracts a certificate from a document and return it as an OpenSSL X509 certificate
    # Return nil is the node cannot be found
    def extract_cert(doc, node, namespace)
      return nil unless doc.respond_to? :at

      cert_raw = doc.at("xmlns|#{node}", 'xmlns' => namespace)

      return nil if cert_raw.nil?

      cert_raw = cert_raw.content.gsub(/\s+/, "")

      cert = process_cert_value(cert_raw)

      begin
        OpenSSL::X509::Certificate.new(cert)
      rescue => e
        fail OpenSSL::X509::CertificateError,
             "The certificate could not be processed. It's most likely corrupted. OpenSSL had this to say: #{e}."
      end
    end
  end
end
