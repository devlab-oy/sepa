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
  end
end
