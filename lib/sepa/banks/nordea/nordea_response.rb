module Sepa
  class NordeaResponse < Response

    def own_signing_cert
      ar = extract_application_response('http://bxd.fi/CertificateService')
      at = 'xmlns|Certificate > xmlns|Certificate'
      xmlns = 'http://filetransfer.nordea.com/xmldata/'
      node = Nokogiri::XML(ar).at(at, xmlns: xmlns)

      return unless node

      cert_value = process_cert_value node.content
      cert = OpenSSL::X509::Certificate.new cert_value
      cert_plain = cert.to_s

      Base64.encode64 cert_plain
    end

  end
end
