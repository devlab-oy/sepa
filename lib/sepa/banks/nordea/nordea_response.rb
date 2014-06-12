module Sepa
  class NordeaResponse < Response

    def initialize(response, command: nil)
      super

      if @command == :get_certificate
        @application_response = extract_application_response('http://bxd.fi/CertificateService')
      end

      @content = extract_own_cert
    end

    def extract_own_cert
      node = Nokogiri::XML(@application_response)
      .at('xmlns|Certificate > xmlns|Certificate', xmlns: 'http://filetransfer.nordea.com/xmldata/')

      OpenSSL::X509::Certificate.new(process_cert_value(node.content)) if node
    end
  end
end
