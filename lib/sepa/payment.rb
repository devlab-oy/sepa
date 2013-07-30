module Sepa
  class Payment
    def initialize(debtor, params)
      @payment_info_id = params.fetch(:payment_info_id)
      @execution_date = params.fetch(:execution_date)
      @salary_or_pension = params[:salary_or_pension]

      @debtor_name = debtor.fetch(:name)
      @debtor_address = debtor.fetch(:address)
      @debtor_country = debtor.fetch(:country)
      @debtor_postcode = debtor.fetch(:postcode)
      @debtor_town = debtor.fetch(:town)
      @debtor_customer_id = debtor.fetch(:customer_id)
      @debtor_iban = debtor.fetch(:iban)
      @debtor_bic = debtor.fetch(:bic)

      @transactions = params.fetch(:transactions)
    end

    # Returns a Nokogiri::XML::Node of the payment.
    def to_node
      node = build.doc.root
      add_transactions(node)
    end

    # Returns the number of transactions in this payment.
    def number_of_transactions
      @transactions.count
    end

    private

      # Builds the payment.
      def build
        Nokogiri::XML::Builder.new do |xml|
          xml.PmtInf {
            xml.PmtInfId @payment_info_id
            xml.PmtMtd 'TRF'

            xml.PmtTpInf {
              xml.SvcLvl {
                xml.Cd 'SEPA'
              }

              # Needs to be specified in case the payment contains salaris or
              # pensions.
              if @salary_or_pension
                xml.CtgyPurp 'SALA'
              end
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

      # Adds the transactions specified in the params hash to the payment.
      def add_transactions(node)
        @transactions.each do |transaction|
          node.add_child(transaction.to_node)
        end

        node
      end
  end
end
