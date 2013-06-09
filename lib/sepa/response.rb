module Sepa
  class Response
    def initialize(response)
      @response = response
      @response.remove_namespaces!
    end

    def verify_soap_digests
      find_digest_values
    end

    private

      # Finds all reference nodes with digest values in the document and returns
      # a hash with uri as the key and digest as the value.
      def find_digest_values
        references = {}
        reference_nodes = @response.css('Reference')

        reference_nodes.each do |node|
          if node.at_css('DigestValue')
            uri = node.attr('URI')
            digest_value = node.at_css('DigestValue').content
            references[uri] = digest_value
          end
        end

        references
      end
  end
end
