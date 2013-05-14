require 'nokogiri'

module Sepa
  class SenderVerifier
    def initialize(soap_response)
      @digest_value = soap_response.
    end

    def calculate_digest
    end
  end
end
