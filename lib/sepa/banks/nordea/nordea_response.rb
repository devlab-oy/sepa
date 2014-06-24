module Sepa
  class NordeaResponse < Response

    # Nordea get_certificate has application_response in different place
    def application_response
      return super unless command == :get_certificate
      extract_application_response('http://bxd.fi/CertificateService')
    end

    # Nordea get_certificate has content in different place
    def content
      return super unless command == :get_certificate
      extract_own_cert
    end

    def extract_own_cert
      at = 'xmlns|Certificate > xmlns|Certificate'
      xmlns = 'http://filetransfer.nordea.com/xmldata/'
      node = Nokogiri::XML(application_response).at(at, xmlns: xmlns)

      Base64.encode64(OpenSSL::X509::Certificate.new(process_cert_value(node.content)).to_s) if node
    end

  end
end
