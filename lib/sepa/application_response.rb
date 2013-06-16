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

    private

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