module Sepa
  class Transaction
    def initialize(params)
      @instruction_id = params[:instruction_id]
      @end_to_end_id = params.fetch(:end_to_end_id)

      if params[:invoice_bundle]
        @amount = 0
        params[:invoice_bundle].each do |invoice|
          @amount += invoice.fetch(:amount).to_f
        end
      else
        @amount = params.fetch(:amount)
      end

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
      @salary = params[:salary]
      @pension = params[:pension]
      @social_security_number = params[:social_security_number]
      @invoice_bundle = params[:invoice_bundle]
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

              if @salary
                xml.Id {
                  xml.PrvtId {
                    xml.SclSctyNb @social_security_number
                  }
                }
              end
            }

            xml.CdtrAcct {
              xml.Id {
                xml.IBAN @iban
              }
            }

            if @pension
              xml.Purp {
                xml.Cd 'PENS'
              }
            end

            xml.RmtInf {
              if @invoice_bundle
                message = ''
                @invoice_bundle.each do |invoice|
                  if invoice[:reference]
                    message += "RFS/#{invoice[:reference]}/"
                  elsif invoice[:invoice_number]
                    message += "INVOICE/#{invoice[:invoice_number]}/"
                  end
                end

                xml.Ustrd message

                @invoice_bundle.each do |invoice|
                  xml.Strd {
                    xml.RfrdDocInf {
                      xml.RfrdDocTp {
                        xml.Cd invoice.fetch(:type)
                      }

                      if invoice[:invoice_number]
                        xml.RfrdDocNb invoice[:invoice_number]
                      end
                    }
                    xml.RfrdDocAmt {
                      if invoice.fetch(:amount).to_f > 0
                        xml.RmtdAmt(invoice[:amount],
                                    :Ccy => invoice[:currency])
                      else
                        xml.CdtNoteAmt(invoice[:amount].to_f.abs,
                                       :Ccy => invoice[:currency])
                      end
                    }

                    if invoice[:reference]
                      xml.CdtrRefInf {
                        xml.CdtrRefTp {
                          xml.Cd 'SCOR'
                        }

                        xml.CdtrRef invoice[:reference]
                      }
                    end
                  }
                end

              elsif @reference
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
