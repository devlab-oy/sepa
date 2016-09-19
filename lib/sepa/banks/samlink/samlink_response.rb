module Sepa
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
  end
end
