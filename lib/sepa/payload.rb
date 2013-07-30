module Sepa
  class Payload
    def initialize(debtor, payments)
      @debtor_name = debtor.fetch(:name)
      @debtor_address = debtor.fetch(:address)
      @debtor_country = debtor.fetch(:country)
      @debtor_postcode = debtor.fetch(:postcode)
      @debtor_town = debtor.fetch(:town)
      @debtor_customer_id = debtor.fetch(:customer_id)

      unless @payments = payments
        fail KeyError, 'No payments provided for the payload.'
      end

      @doc = build
    end

    def to_xml
       @doc.to_xml
    end

    # Checks whether the payload validates against the schema.
    def valid?
      @xsd ||= load_schema
      @xsd.valid?(@doc)
    end

    # Errors that a schema validation of the document produces.
    def errors
      @xsd ||= load_schema
      @xsd.validate(@doc).collect { |e| e.message }
    end

    private

      def build
        doc = build_root
        doc = build_group_header(doc)
        add_payments(doc)
      end

      # Gets the number of transactions in this payload.
      def number_of_transactions
        count = 0
        @payments.each { |payment| count += payment.number_of_transactions }
        count
      end

      # Builds the root and pain elements with namespace and schema definitions.
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

      # Builds the group header.
      def build_group_header(root_e)
        builder = Nokogiri::XML::Builder.with(root_e.at('Document > *')) do |xml|
          xml.GrpHdr {
            xml.MsgId SecureRandom.hex(17)
            xml.CreDtTm Time.new.iso8601
            xml.BtchBookg 'true'
            xml.NbOfTxs number_of_transactions
            xml.Grpg 'MIXD'
            xml.InitgPty {
              xml.Nm @debtor_name
              xml.PstlAdr {
                xml.AdrLine @debtor_address
                xml.AdrLine "#{@debtor_country}-#{@debtor_postcode}"
                xml.StrtNm @debtor_address
                xml.PstCd "#{@debtor_country}-#{@debtor_postcode}"
                xml.TwnNm @debtor_town
                xml.Ctry @debtor_country
              }
            }
          }
        end

        builder.doc
      end

      # Adds all the payments specified in the parameters to the payload.
      def add_payments(root_e)
        @payments.each do |payment|
          root_e.at(
            '/xmlns:Document/xmlns:pain.001.001.02',
            'xmlns' => 'urn:iso:std:iso:20022:tech:xsd:pain.001.001.02'
          ).add_child(payment.to_node)
        end

        root_e
      end

      def load_schema
        schemas_path = File.expand_path('../../../lib/sepa/xml_schemas', __FILE__)
        xsd = Nokogiri::XML::Schema(File.read("#{schemas_path}/pain.001.001.02.xsd"))
      end

  end
end
