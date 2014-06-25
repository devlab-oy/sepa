module Sepa
  class NordeaResponse < Response
    include Utilities

    def own_signing_cert
      application_response = extract_application_response(NORDEA_PKI)
      at = 'xmlns|Certificate > xmlns|Certificate'
      node = Nokogiri::XML(application_response).at(at, xmlns: NORDEA_XML_DATA)

      return unless node

      cert_value = process_cert_value node.content
      cert = x509_certificate cert_value
      cert_plain = cert.to_s

      encode cert_plain
    end

  end
end
