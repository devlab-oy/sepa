module Sepa
  class ApplicationResponse
    def initialize(ar)
      @ar = ar

      if !@ar.respond_to?(:canonicalize)
        fail ArgumentError,
          "The application response you provided is not a valid Nokogiri::XML" \
          " file."
      elsif !valid_against_ar_schema?(@ar)
        fail ArgumentError,
          "The application response you provided doesn't validate against" \
          " application response schema."
      end
    end

    def hashes_match?
      ar = @ar.clone

      digest_value = ar.at_css(
        'xmlns|DigestValue',
        'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
      ).content.strip

      ar.at_css(
        "xmlns|Signature",
        'xmlns' => 'http://www.w3.org/2000/09/xmldsig#'
      ).remove

      actual_digest = OpenSSL::Digest::SHA1.new.digest(ar.canonicalize)
      actual_digest = Base64.encode64(actual_digest).strip

      if digest_value == actual_digest
        true
      else
        false
      end
    end

    private

      def calculate_digest(node)
        sha1 = OpenSSL::Digest::SHA1.new

        canon_node = node.canonicalize(
          mode=Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0,
          inclusive_namespaces=nil,with_comments=false
        )

        Base64.encode64(sha1.digest(canon_node)).gsub(/\s+/, "")
      end

      def valid_against_ar_schema?(doc)
        schemas_path = File.expand_path('../../../lib/sepa/xml_schemas',
                                        __FILE__)

        Dir.chdir(schemas_path) do
          xsd = Nokogiri::XML::Schema(IO.read('application_response.xsd'))
          xsd.valid?(doc)
        end
      end
  end
end
