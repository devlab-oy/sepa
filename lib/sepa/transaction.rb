module Sepa
  class Transaction
    def initialize(params)
      @instruction_id = params[:instruction_id]
      @end_to_end_id = params.fetch(:end_to_end_id)
      @amount = params.fetch(:amount)
      @currency = params.fetch(:currency)
      @bic = params.fetch(:bic)
      @name = params.fetch(:name)
      @address = params.fetch(:address)
      @country = params.fetch(:country)
      @postcode = params.fetch(:postcode)
      @town = params.fetch(:town)
      @iban = params.fetch(:iban)
      @reference = params[:reference]
      @message = params[:message]
    end

    def to_node
      build.doc.root
    end

    private

      def build
        Nokogiri::XML::Builder.new do |xml|
          xml.CdtTrfTxInf {
            xml.PmtId {
              if @instruction_id
                xml.InstrId @instruction_id
              end
              xml.EndToEndId @end_to_end_id
            }

            xml.Amt {
              xml.InstdAmt(@amount, :Ccy => @currency)
            }

            xml.CdtrAgt {
              xml.FinInstnId {
                xml.BIC @bic
              }
            }

            xml.Cdtr {
              xml.Nm @name
              xml.PstlAdr {
                xml.AdrLine @address
                xml.AdrLine("#{@country}-#{@postcode} " \
                            "#{@town}")
                xml.StrtNm @address
                xml.PstCd "#{@country}-#{@postcode}"
                xml.TwnNm @town
                xml.Ctry @country
              }
            }

            xml.CdtrAcct {
              xml.Id {
                xml.IBAN @iban
              }
            }

            xml.RmtInf {
              if @reference
                xml.Strd {
                  xml.CdtrRefInf {
                    xml.CdtrRefTp {
                      xml.Cd 'SCOR'
                    }

                    xml.CdtrRef @reference
                  }
                }

              else
                xml.Ustrd @message
              end
            }
          }
        end
      end
  end
end
