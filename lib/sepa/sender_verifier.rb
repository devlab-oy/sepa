require 'nokogiri'

module Sepa
  class SenderVerifier
    def initialize(soap_response)
      @soap_response = Nokogiri::XML(soap_response)
    end

    def get_digest_values
      @soap_response.remove_namespaces!
      digest_nodes = @soap_response.xpath("//Reference/dsig:DigestValue")
    end

    def calculate_digest
    end
  end
end
