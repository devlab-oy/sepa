module Sepa
  class Payment
    def initialize(params)
      @payment_info_id = params.fetch(:payment_info_id)
      @execution_date = params.fetch(:execution_date)

      @debtor_name = debtor.fetch(:name)
      @debtor_address = debtor.fetch(:address)
      @debtor_country = debtor.fetch(:country)
      @debtor_postcode = debtor.fetch(:postcode)
      @debtor_town = debtor.fetch(:town)
      @debtor_customer_id = debtor.fetch(:customer_id)
      @debtor_y_tunnus = debtor.fetch(:y_tunnus)
      @debtor_iban = debtor.fetch(:iban)
      @debtor_bic = debtor.fetch(:bic)

      @transactions = transactions
    end

    def to_node
      build.doc.root
    end

    private

      def build
        Nokogiri::XML::Builder.new do |xml|
          xml.PmtInf {
            xml.PmtInfId @payment_info_id
            xml.PmtMtd 'TRF'

            xml.PmtTpInf {
              xml.SvcLvl {
                xml.Cd 'SEPA'
              }
            }

            xml.ReqdExctnDt @execution_date
            xml.Dbtr {
              xml.Nm @debtor_name
              xml.PstlAdr {
                xml.AdrLine @debtor_address
                xml.AdrLine "#{@debtor_country}-#{@debtor_postcode} " \
                "#{@debtor_town}"
                xml.Ctry @debtor_country
              }

              xml.Id {
                xml.OrgId {
                  if @debtor_customer_id
                    xml.BkPtyId @debtor_customer_id
                  else
                    xml.BkPtyId @debtor_y_tunnus
                  end
                }
              }
            }

            xml.DbtrAcct {
              xml.Id {
                xml.IBAN @debtor_iban
              }
            }

            xml.DbtrAgt {
              xml.FinInstnId {
                xml.BIC @debtor_bic
              }
            }

            xml.ChrgBr 'SLEV'
          }
        end
      end
  end
end
