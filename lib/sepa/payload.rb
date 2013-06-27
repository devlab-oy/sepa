module Sepa
  class Payload
    def initialize(params)
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.Document {
          xml.send 'pain.001.001.02'
        }
      end

      builder.to_xml
    end
  end
end
''