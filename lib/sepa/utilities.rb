module Sepa
  module Utilities

    def calculate_digest(node)
      sha1 = OpenSSL::Digest::SHA1.new

      canon_node = canonicalize_exclusively node

      encode(sha1.digest(canon_node)).gsub(/\s+/, "")
    end

    # Takes a certificate, adds begin and end
    # certificate texts and splits it into multiple lines so that OpenSSL
    # can read it.
    def process_cert_value(cert_value)
      cert = "-----BEGIN CERTIFICATE-----\n"
      cert << cert_value.to_s.gsub(/\s+/, "").scan(/.{1,64}/).join("\n")
      cert << "\n"
      cert << "-----END CERTIFICATE-----"
    end

    def format_cert(cert)
      cert = cert.to_s
      cert = cert.split('-----BEGIN CERTIFICATE-----')[1]
      cert = cert.split('-----END CERTIFICATE-----')[0]
      cert.gsub!(/\s+/, "")
    end

    def format_cert_request(cert_request)
      cert_request = cert_request.split('-----BEGIN CERTIFICATE REQUEST-----')[1]
      cert_request = cert_request.split('-----END CERTIFICATE REQUEST-----')[0]
      cert_request.gsub!(/\s+/, "")
    end

    def check_validity_against_schema(doc, schema)
      Dir.chdir(SCHEMA_PATH) do
        xsd = Nokogiri::XML::Schema(IO.read(schema))
        unless doc.respond_to?(:canonicalize) && xsd.valid?(doc)
          errors.add(:base, 'The document did not validate against the schema file')
        end
      end
    end

    # Extracts a certificate from a document and return it as an OpenSSL X509 certificate
    # Return nil is the node cannot be found
    def extract_cert(doc, node, namespace)
      cert_raw = doc.at("xmlns|#{node}", 'xmlns' => namespace)

      return nil unless cert_raw

      cert_raw = cert_raw.content.gsub(/\s+/, "")

      cert = process_cert_value(cert_raw)

      begin
        x509_certificate(cert)
      rescue => e
        fail OpenSSL::X509::CertificateError,
             "The certificate could not be processed. It's most likely corrupted. OpenSSL had this to say: #{e}."
      end
    end

    def cert_request_valid?(cert_request)
      begin
        OpenSSL::X509::Request.new cert_request
      rescue
        return false
      end

      true
    end

    def load_body_template(template)
      path = "#{template}/"

      case @command
      when :download_file_list
        path << "download_file_list.xml"
      when :get_user_info
        path << "get_user_info.xml"
      when :upload_file
        path << "upload_file.xml"
      when :download_file
        path << "download_file.xml"
      when :get_certificate
        path << "get_certificate.xml"
      when :get_bank_certificate
        path << "danske_get_bank_certificate.xml"
      when :create_certificate
        path << "create_certificate.xml"
      else
        fail ArgumentError
      end

      xml_doc(File.open(path))
    end

    # Checks that the certificate in the application response is signed with the
    # private key of the public key of the certificate as parameter.
    def cert_is_trusted(root_cert)
      if root_cert.subject == certificate.issuer
        # Return true or false
        certificate.verify(root_cert.public_key)
      else
        fail SecurityError, "false"
      end
    end

    def iso_time
      @iso_time ||= Time.now.utc.iso8601
    end

    def hmac(pin, csr)
      encode(OpenSSL::HMAC.digest('sha1', pin, csr)).chop
    end

    def csr_to_binary(csr)
      OpenSSL::X509::Request.new(csr).to_der
    end

    def canonicalized_node(doc, namespace, node)
      content_node = doc.at("xmlns|#{node}", xmlns: namespace)
      content_node.canonicalize if content_node
    end

    def xml_doc(value)
      Nokogiri::XML value if value
    end

    def decode(value)
      Base64.decode64 value
    end

    def canonicalize_exclusively(value)
      value.canonicalize(mode = Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
                         inclusive_namespaces = nil,
                         with_comments = false)
    end

    def x509_certificate(value)
      OpenSSL::X509::Certificate.new value
    end

    def encode(value)
      Base64.encode64 value
    end

    def rsa_key(key_as_string)
      OpenSSL::PKey::RSA.new key_as_string
    end

  end
end
