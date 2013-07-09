module Sepa
  class Payload
    def initialize(debtor, payment)
      @debtor_name = debtor.fetch(:name)
      @debtor_address = debtor.fetch(:address)
      @debtor_country = debtor.fetch(:country)
      @debtor_postcode = debtor.fetch(:postcode)
      @debtor_town = debtor.fetch(:town)
      @debtor_customer_id = debtor.fetch(:customer_id)
      @debtor_y_tunnus = debtor.fetch(:y_tunnus)
      @debtor_iban = debtor.fetch(:iban)
      @debtor_bic = debtor.fetch(:bic)

      @payment_info_id = payment.fetch(:payment_info_id)
      @execution_date = payment.fetch(:execution_date)
      @payment_id = payment.fetch(:payment_id)
      @end_to_end_id = payment.fetch(:end_to_end_id)
      @amount = payment.fetch(:amount)
      @currency = payment.fetch(:currency)
      @payment_bic = payment.fetch(:bic)
    end

    def to_xml
      doc = build_root
      doc = build_group_header(doc)
      doc = build_payment_info(doc)
      doc = build_credit_transfer(doc)
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

    def build_payment_info(root_e)
      builder = Nokogiri::XML::Builder.with(root_e.at('Document > *')) do |xml|
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
              xml.AdrLine "#{@debtor_country}-#{@debtor_postcode} #{@debtor_town}"
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

      builder.doc
    end

    def build_credit_transfer(root_e)
      Nokogiri::XML::Builder.with(root_e.at('PmtInf')) do |xml|
        xml.CdtTrfTxInf {
          xml.PmtId {
            xml.InstrId @payment_id
            xml.EndToEndId @end_to_end_id
          }

          xml.Amt {
            xml.InstdAmt(@amount, :Ccy => @currency)
          }

          xml.CdtrAgt {
            xml.FinInstnId {
              xml.BIC @payment_bic
            }
          }
        }
      end
    end
  end
end
