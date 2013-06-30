module Sepa
  class Payload
    def initialize(params)
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.Document(
          xmlns: 'urn:iso:std:iso:20022:tech:xsd:pain.001.001.02',
          'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
          'xsi:schemaLocation' => 'urn:iso:std:iso:20022:tech:xsd:pain.001.' \
          '001.02 pain.001.001.02.xsd'
        ) {
          xml.send 'pain.001.001.02'
        }
      end

      builder.to_xml
    end
  end
end
