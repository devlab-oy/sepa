module Sepa
  # Handles Samlink specific response logic. Mainly certificate specific stuff.
  class SamlinkResponse < Response
    # @see Response#response_code
    def response_code
      super(namespace: SAMLINK_PKI)
    end

    # @see Response#response_code
    def response_text
      super(namespace: SAMLINK_PKI)
    end

    def application_response
      super(namespace: SAMLINK_PKI)
    end

    def own_signing_certificate
      (node = Nokogiri::XML(application_response).at('xmlns|Certificate > xmlns|Certificate', xmlns: OP_XML_DATA)) &&
        (content = node.content) &&
        x509_certificate(decode(content)).to_s
    end

    def certificate_is_trusted?
      verify_certificate_against_root_certificate(certificate, SAMLINK_ROOT_CERTIFICATE)
    end
  end
end
