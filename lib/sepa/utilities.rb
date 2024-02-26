module Sepa
  # Contains utility methods that are used in this gem.
  module Utilities
    # Calculates a SHA1 digest for a given node. Before the calculation, the node is canonicalized
    # exclusively.
    #
    # @param node [Nokogiri::Node] the node which the digest is calculated from
    # @return [String] the calculated digest
    def calculate_digest(node, digest_method: :sha1)
      case digest_method
        when :sha256
          #print "DOING 256 FOR DIGEST IN UTILS"
          sha = OpenSSL::Digest::SHA256.new
        else
          #print "DOING 1 FOR DIGEST IN UTILS"
          sha = OpenSSL::Digest::SHA1.new
      end
      
      canon_node = canonicalize_exclusively(node)

      encode(sha.digest(canon_node)).gsub(/\s+/, "")
    end

    # Takes a certificate, adds begin and end certificate texts and splits it into multiple lines so
    # that OpenSSL can read it.
    #
    # @param cert_value [#to_s] the certificate to be processed
    # @return [String] the processed certificate
    # @todo rename maybe because this seems more formatting than {#format_cert}
    def process_cert_value(cert_value)
      cert = "-----BEGIN CERTIFICATE-----\n"
      cert << cert_value.to_s.gsub(/\s+/, "").scan(/.{1,64}/).join("\n")
      cert << "\n"
      cert << "-----END CERTIFICATE-----"
    end

    # Removes begin and end certificate texts from a certificate and removes whitespaces to make the
    # certificate read to be embedded in xml.
    #
    # @param cert [#to_s] The certificate to be formatted
    # @return [String] the formatted certificate
    # @todo rename maybe
    # @see #process_cert_value
    def format_cert(cert)
      cert = cert.to_s
      cert = cert.split('-----BEGIN CERTIFICATE-----')[1]
      cert = cert.split('-----END CERTIFICATE-----')[0]
      cert.gsub!(/\s+/, "")
    end

    # Removes begin and end certificate request texts from a certificate signing request and removes
    # whitespaces
    #
    # @param cert_request [String] the certificate request to be formatted
    # @return [String] the formatted certificate request
    # @todo rename
    def format_cert_request(cert_request)
      cert_request = cert_request.split('-----BEGIN CERTIFICATE REQUEST-----')[1]
      cert_request = cert_request.split('-----END CERTIFICATE REQUEST-----')[0]
      cert_request.gsub!(/\s+/, "")
    end

    # Validates whether a doc is valid against a schema. Adds error using ActiveModel validations if
    # document is not valid against the schema.
    #
    # @param doc [Nokogiri::XML::Document] the document to validate
    # @param schema [String] name of the schema file in {SCHEMA_PATH}
    def check_validity_against_schema(doc, schema)
      Dir.chdir(SCHEMA_PATH) do
        xsd = Nokogiri::XML::Schema(IO.read(schema))
        unless doc.respond_to?(:canonicalize) && xsd.valid?(doc)
          errors.add(:base, 'The document did not validate against the schema file')
        end
      end
    end

    # Extracts a certificate from a document and returns it as an OpenSSL X509 certificate. Returns
    # nil if the node cannot be found
    #
    # @param doc [Nokogiri::XML::Document] the document that contains the certificate node
    # @param node [String] the name of the node that contains the certificate
    # @param namespace [String] the namespace of the certificate node
    # @return [OpenSSL::X509::Certificate] the extracted certificate if it is extracted successfully
    # @return [nil] if the certificate cannot be found
    # @raise [OpenSSL::X509::CertificateError] if there is a problem with the certificate
    # @todo refactor not to fail
    def extract_cert(doc, node, namespace)
      cert_raw = doc.at("xmlns|#{node}", 'xmlns' => namespace)

      return nil unless cert_raw

      cert_raw = cert_raw.content.gsub(/\s+/, "")

      cert = process_cert_value(cert_raw)

      begin
        x509_certificate(cert)
      rescue => e
        raise OpenSSL::X509::CertificateError,
              "The certificate could not be processed. It's most likely corrupted. " \
              "OpenSSL had this to say: #{e}."
      end
    end

    # Checks whether a certificate signing request is valid
    #
    # @param cert_request [#to_s] the certificate signing request
    # @return [true] if the certificate signing request is valid
    # @return [false] if the certificate signing request is not valid
    # @todo rename
    def cert_request_valid?(cert_request)
      begin
        OpenSSL::X509::Request.new cert_request
      rescue
        return false
      end

      true
    end

    # Loads a soap or application request xml template according to a parameter and command.
    #
    # @param template [String] path to a template directory. Currently supported values are defined
    #   in contants {AR_TEMPLATE_PATH} and {SOAP_TEMPLATE_PATH}.
    # @return [Nokogiri::XML::Document] the loaded template
    # @raise [ArgumentError] if a template cannot be found for a command
    def load_body_template(template)
      raise ArgumentError, 'Unsupported command' unless SUPPORTED_COMMANDS.include?(@command)

      file = if STANDARD_COMMANDS.include?(@command)
               "#{template}/#{@command}.xml"
             else
               "#{template}/#{@bank}/#{@command}.xml"
             end

      xml_doc(File.open(file))
    end

    # Gets current utc time in iso-format
    #
    # @return [String] current utc time in iso-format
    def iso_time
      @iso_time ||= Time.now.utc.iso8601
    end

    # Calculates an HMAC for a given pin and certificate signing request. Used by Nordea certificate
    # requests.
    #
    # @param pin [#to_s] the one-time pin number got from bank
    # @param csr [#to_s] the certificate signing request
    # @return [String] the generated HMAC for the values
    def hmac(pin, csr)
      encode(OpenSSL::HMAC.digest('sha1', pin, csr)).chop
    end

    # Converts a certificate signing request from base64 encoded string to binary string
    #
    # @param csr [#to_s] certificate signing request in base64 encoded format
    # @return [String] the certificate signing request in binary format
    def csr_to_binary(csr)
      OpenSSL::X509::Request.new(csr).to_der
    end

    # Canonicalizes a node inclusively
    #
    # @param doc [Nokogiri::XML::Document] the document that contains the node
    # @param namespace [String] the namespace of the node
    # @param node [String] name of the node
    # @return [String] the canonicalized node if the node can be found
    # @return [nil] if the node cannot be found
    def canonicalized_node(doc, namespace, node)
      content_node = doc.at("xmlns|#{node}", xmlns: namespace)
      content_node.canonicalize if content_node
    end

    # Converts an xml string to a nokogiri document
    #
    # @param value [to_s] the xml document
    # @return [Nokogiri::XML::Document] the xml document
    def xml_doc(value)
      Nokogiri::XML value
    end

    # Decodes a base64 encoded string
    #
    # @param value [#to_s] the base64 encoded string
    # @return [String] the decoded string
    def decode(value)
      Base64.decode64 value
    end

    # Canonicalizes an xml node exclusively without comments
    #
    # @param value [Nokogiri::XML::Node, #canonicalize] the node to be canonicalized
    # @return [String] the canonicalized node
    def canonicalize_exclusively(value)
      value.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
    end

    # Creates a new OpenSSL X509 certificate from a string
    #
    # @param value [#to_s] the string from which to create the certificate
    # @return [OpenSSL::X509::Certificate] the OpenSSL X509 certificate
    # @example Example certificate to convert
    #   "-----BEGIN CERTIFICATE-----
    #   MIIDwTCCAqmgAwIBAgIEAX1JuTANBgkqhkiG9w0BAQUFADBkMQswCQYDVQQGEwJT
    #   RTEeMBwGA1UEChMVTm9yZGVhIEJhbmsgQUIgKHB1YmwpMR8wHQYDVQQDExZOb3Jk
    #   ZWEgQ29ycG9yYXRlIENBIDAxMRQwEgYDVQQFEws1MTY0MDYtMDEyMDAeFw0xMzA1
    #   MDIxMjI2MzRaFw0xNTA1MDIxMjI2MzRaMEQxCzAJBgNVBAYTAkZJMSAwHgYDVQQD
    #   DBdOb3JkZWEgRGVtbyBDZXJ0aWZpY2F0ZTETMBEGA1UEBRMKNTc4MDg2MDIzODCB
    #   nzANBgkqhkiG9w0BAQEFAAOBjQAwgYkCgYEAwtFEfAtbJuGzQwwRumZkvYh2BjGY
    #   VsAMUeiKtOne3bZSeisfCq+TXqL1gI9LofyeAQ9I/sDm6tL80yrD5iaSUqVm6A73
    #   9MsmpW/iyZcVf7ms8xAN51ESUgN6akwZCU9pH62ngJDj2gUsktY0fpsoVsARdrvO
    #   Fk0fTSUXKWd6LbcCAwEAAaOCAR0wggEZMAkGA1UdEwQCMAAwEQYDVR0OBAoECEBw
    #   2cj7+XMAMBMGA1UdIAQMMAowCAYGKoVwRwEDMBMGA1UdIwQMMAqACEALddbbzwun
    #   MDcGCCsGAQUFBwEBBCswKTAnBggrBgEFBQcwAYYbaHR0cDovL29jc3Aubm9yZGVh
    #   LnNlL0NDQTAxMA4GA1UdDwEB/wQEAwIFoDCBhQYDVR0fBH4wfDB6oHigdoZ0bGRh
    #   cCUzQS8vbGRhcC5uYi5zZS9jbiUzRE5vcmRlYStDb3Jwb3JhdGUrQ0ErMDElMkNv
    #   JTNETm9yZGVhK0JhbmsrQUIrJTI4cHVibCUyOSUyQ2MlM0RTRSUzRmNlcnRpZmlj
    #   YXRlcmV2b2NhdGlvbmxpc3QwDQYJKoZIhvcNAQEFBQADggEBACLUPB1Gmq6286/s
    #   ROADo7N+w3eViGJ2fuOTLMy4R0UHOznKZNsuk4zAbS2KycbZsE5py4L8o+IYoaS8
    #   8YHtEeckr2oqHnPpz/0Eg7wItj8Ad+AFWJqzbn6Hu/LQhlnl5JEzXzl3eZj9oiiJ
    #   1q/2CGXvFomY7S4tgpWRmYULtCK6jode0NhgNnAgOI9uy76pSS16aDoiQWUJqQgV
    #   ydowAnqS9h9aQ6gedwbOdtkWmwKMDVXU6aRz9Gvk+JeYJhtpuP3OPNGbbC5L7NVd
    #   no+B6AtwxmG3ozd+mPcMeVuz6kKLAmQyIiBSrRNa5OrTkq/CUzxO9WUgTnm/Sri7
    #   zReR6mU=
    #   -----END CERTIFICATE-----"
    def x509_certificate(value)
      OpenSSL::X509::Certificate.new value
    end

    # Base64 encodes a given value
    #
    # @param value [#to_s] the value to be encoded
    # @return [String] the base64 encoded string
    def encode(value)
      Base64.encode64 value
    end

    # Creates a new OpenSSL RSA key from a string key
    #
    # @param key_as_string [to_s] the key as a string
    # @return [OpenSSL::PKey::RSA] the OpenSSL RSA key
    # @example Example key to convert
    #   "-----BEGIN PRIVATE KEY-----
    #   MIICdwIBADANBgkqhkiG9w0BAQEFAASCAmEwggJdAgEAAoGBAMLRRHwLWybhs0MM
    #   EbpmZL2IdgYxmFbADFHoirTp3t22UnorHwqvk16i9YCPS6H8ngEPSP7A5urS/NMq
    #   w+YmklKlZugO9/TLJqVv4smXFX+5rPMQDedRElIDempMGQlPaR+tp4CQ49oFLJLW
    #   NH6bKFbAEXa7zhZNH00lFylnei23AgMBAAECgYEAqt912/7x4jaQTrxlSELLFVp9
    #   eo1BesVTiPwXvPpsGbbyvGjZ/ztkXNs9zZbh1aCGzZMkiR2U7F5GlsiprlIif4cF
    #   6Xz7rCjaAs7iDRt9PjhjVuqNGR2I+VIIlbQ9XWFJ3lJFW3v7TIZ8JbLnn0XOFz+Z
    #   BBSSGTK1zTNh4TBQtjECQQDe5M3uu9m4RwSw9R6GaDw/IFQZgr0oWSv0WIjRwvwW
    #   nFnSX2lbkNAjulP0daGsmn7vxIpqZxPxwcrU4wFqTF5dAkEA38DnbCm3YfogzwLH
    #   Nre2hBmGqjWarhtxqtRarrkgnmOd8W0Z1Hb1dSHrliUSVSrINbK5ZdEV15Rpu7VD
    #   OePzIwJAPMslS+8alANyyR0iJUC65fDYX1jkZOPldDDNqIDJJxWf/hwd7WaTDpuc
    #   mHmZDi3ZX2Y45oqUywSzYNtFoIuR1QJAZYUZuyqmSK77SdGB36K1DfSi9AFEQDC1
    #   fwPAbTwTv6mFFPAiYxLiRZXxVPtW+QtjMXH4ymh2V4y/+GnCqbZyLwJBAJQSDAME
    #   Sn4Uz7Zjk3UrBIbMYEv0u2mcCypwsb0nGE5/gzDPjGE9cxWW+rXARIs+sNQVClnh
    #   45nhdfYxOjgYff0=
    #   -----END PRIVATE KEY-----"
    def rsa_key(key_as_string)
      OpenSSL::PKey::RSA.new key_as_string
    end

    # Generates a random id for a node in soap and sets it to the soap header
    #
    # @param document [Nokogiri::XML::Document] the document that contains the node
    # @param namespace [String] the namespace of the node
    # @param node [String] name of the node
    # @param position [Integer] the soap header might contain many references and this parameter
    # defines which reference is used. Numbering starts from 0.
    # @return [String] the generated id of the node
    # @todo create functionality to automatically add reference nodes to header so than position is
    #   not needed
    def set_node_id(document, namespace, node, position)
      node_id = "#{node.downcase}-#{SecureRandom.uuid}"
      document.at("xmlns|#{node}", xmlns: namespace)['wsu:Id'] = node_id
      @header_template.css('dsig|Reference')[position]['URI'] = "##{node_id}"

      node_id
    end

    # Verifies that a signature has been created with the private key of a certificate
    #
    # @param doc [Nokogiri::XML::Document] the document that contains the signature
    # @param certificate [OpenSSL::X509::Certificate] the certificate to verify the signature
    #   against
    # @param canonicalization_method [Symbol] The canonicalization method that has been used to
    #   canonicalize the SignedInfo node. Accepts `:normal` or `:exclusive`.
    # @return [true] if signature verifies
    # @return [false] if signature fails to verify or if it cannot be found
    def validate_signature(doc, certificate, canonicalization_method)
      node = doc.at('xmlns|SignedInfo', xmlns: DSIG)

      return false unless node

      node = case canonicalization_method
             when :normal
               node.canonicalize
             when :exclusive
               canonicalize_exclusively node
             end

      signature = doc.at('xmlns|SignatureValue', xmlns: DSIG).content
      signature = decode(signature)

      # Return true or false
      certificate.public_key.verify(OpenSSL::Digest::SHA1.new, signature, node)
    end

    # Verifies that a certificate has been signed by the private key of a root certificate
    #
    # @param certificate [OpenSSL::X509::Certificate] the certificate to verify
    # @param root_certificate [OpenSSL::X509::Certificate] the root certificate
    # @return [true] if the certificate has been signed by the private key of the root certificate
    # @return [false] if the certificate has not been signed by the private key of the root
    #   certificate, the certificates are nil or the subject of the root certificate is not the
    #   issuer of the certificate
    def verify_certificate_against_root_certificate(certificate, root_certificate)
      return false unless certificate && root_certificate
      return false unless root_certificate.subject == certificate.issuer

      certificate.verify(root_certificate.public_key)
    end
  end
end
