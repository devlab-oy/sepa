module Sepa
  # Handles Samlink specific response logic. Mainly certificate specific stuff.
  class SamlinkResponse < Response
    # Returns the response code in the response. Overrides {Response#response_code} if {#command} is
    # `:get_certificate`, because the namespace is different with that command.
    #
    # @return [String] response code if it is found
    # @return [nil] if response code cannot be found
    # @see Response#response_code
    def response_code
      return super unless [:get_certificate].include? command

      node = doc.at('xmlns|ResponseCode', xmlns: SAMLINK_PKI)
      node.content if node
    end

    # Returns the response text in the response. Overrides {Response#response_text} if {#command} is
    # `:get_certificate`, because the namespace is different with that command.
    #
    # @return [String] response text if it is found
    # @return [nil] if response text cannot be found
    # @see Response#response_text
    def response_text
      return super unless [:get_certificate].include? command

      node = doc.at('xmlns|ResponseText', xmlns: SAMLINK_PKI)
      node.content if node
    end
  end
end
