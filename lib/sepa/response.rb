module Sepa
  class Response
    def initialize(response)
      @response = response
      unless valid_against_schema?(@response)
        fail ArgumentError, "The response doesn't validate against schema"
      end
    end

    # Verifies that all digest values in the document match the actual ones.
    def soap_hashes_match?
      digests = find_digest_values(@response)
      nodes = find_nodes_to_verify(@response, digests)

      verified_digests = digests.select do |uri, digest|
        uri = uri.sub(/^#/, '')
        digest == nodes[uri]
      end

      if digests == verified_digests
        true
      else
        false
      end
    end

    private

      # Finds all reference nodes with digest values in the document and returns
      # a hash with uri as the key and digest as the value.
      def find_digest_values(doc)
        references = {}
        reference_nodes = @response.css(
          'xmlns|Reference',
          'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
        )

        reference_nodes.each do |node|
          uri = node.attr('URI')
          digest_value = node.at_css(
            'xmlns|DigestValue',
            'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
          ).content

          references[uri] = digest_value
        end

        references
      end

      def find_nodes_to_verify(doc, references)
        nodes = {}
        references.each do |uri, digest_value|
          uri = uri.sub(/^#/, '')
          node = doc.at_css(
            "[wsu|Id='" + uri + "']",
            'wsu' => 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss' \
            '-wssecurity-utility-1.0.xsd'
          )

          nodes[uri] = calculate_digest(node)
        end

        nodes
      end

      def calculate_digest(node)
        sha1 = OpenSSL::Digest::SHA1.new

        canon_node = node.canonicalize(
          mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
          inclusive_namespaces=nil,with_comments=false
        )

        Base64.encode64(sha1.digest(canon_node)).gsub(/\s+/, "")
      end

      def valid_against_schema?(doc)
        schemas_path = File.expand_path('../../../lib/sepa/xml_schemas',
                                        __FILE__)

        Dir.chdir(schemas_path) do
          xsd = Nokogiri::XML::Schema(IO.read('soap.xsd'))
          xsd.valid?(doc)
        end
      end
  end
end
