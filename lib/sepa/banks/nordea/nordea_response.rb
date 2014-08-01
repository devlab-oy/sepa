module Sepa
  class NordeaResponse < Response
    include Utilities

    def own_signing_certificate
      application_response = extract_application_response(NORDEA_PKI)
      at = 'xmlns|Certificate > xmlns|Certificate'
      node = Nokogiri::XML(application_response).at(at, xmlns: NORDEA_XML_DATA)

      return unless node

      cert_value = process_cert_value node.content
      cert = x509_certificate cert_value
      cert.to_s
    end

    def response_code
      return super unless command == :get_certificate

      node = doc.at('xmlns|ResponseCode', xmlns: NORDEA_PKI)
      node.content if node
    end

  end
end
