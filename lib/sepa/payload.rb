module Sepa
  class Payload
    def initialize(params)
      @name = params.fetch(:name)
      @address = params.fetch(:address)
      @country = params.fetch(:country)
      @postcode = params.fetch(:postcode)
      @town = params.fetch(:town)
      @payment_id = params.fetch(:payment_id)
    end

    def to_xml
      doc = build_root
      doc = build_group_header(doc)
      doc = build_payment_info(doc)
      doc.to_xml
    end

    def build_root
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

      builder.doc
    end

    def build_group_header(root_e)
      builder = Nokogiri::XML::Builder.with(root_e.at('Document > *')) do |xml|
        xml.GrpHdr {
          xml.MsgId SecureRandom.hex(17)
          xml.CreDtTm Time.new.iso8601
          xml.BtchBookg 'true'
          xml.NbOfTxs 0
          xml.Grpg 'MIXD'
          xml.InitgPty {
            xml.Nm @name
            xml.PstlAdr {
              xml.AdrLine @address
              xml.AdrLine "#{@country}-#{@postcode}"
              xml.StrtNm @address
              xml.PstCd "#{@country}-#{@postcode}"
              xml.TwnNm @town
              xml.Ctry @country
            }
          }
        }
      end

      builder.doc
    end

    def build_payment_info(root_e)
      Nokogiri::XML::Builder.with(root_e.at('Document > *')) do |xml|
        xml.PmtInf {
          xml.PmtInfId @payment_id
        }
      end
    end
  end
end
