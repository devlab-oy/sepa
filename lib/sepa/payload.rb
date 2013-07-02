module Sepa
  class Payload
    def initialize(payer, payee)
      @payer_name = payer.fetch(:name)
      @payer_address = payer.fetch(:address)
      @payer_country = payer.fetch(:country)
      @payer_postcode = payer.fetch(:postcode)
      @payer_town = payer.fetch(:town)

      @payment_id = payee.fetch(:payment_id)
      @sepa_country = payee.fetch(:sepa_country)
      @execution_date = payee.fetch(:execution_date)
      @payee_customer_id = payee.fetch(:customer_id)
      @payee_y_tunnus = payee.fetch(:y_tunnus)
      @payee_iban = payee.fetch(:iban)
      @payee_bic = payee.fetch(:bic)
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
            xml.Nm @payer_name
            xml.PstlAdr {
              xml.AdrLine @payer_address
              xml.AdrLine "#{@payer_country}-#{@payer_postcode}"
              xml.StrtNm @payer_address
              xml.PstCd "#{@payer_country}-#{@payer_postcode}"
              xml.TwnNm @payer_town
              xml.Ctry @payer_country
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
          xml.PmtMtd 'TRF'

          if @sepa_country
            xml.PmtTpInf {
              xml.SvcLvl {
                xml.Cd 'SEPA'
              }
            }
          end

          xml.ReqdExctnDt @execution_date
          xml.Dbtr {
            xml.Nm @payer_name
            xml.PstlAdr {
              xml.AdrLine @payer_address
              xml.AdrLine "#{@payer_country}-#{@payer_postcode} #{@payer_town}"
              xml.Ctry @payer_country
            }

            xml.Id {
              xml.OrgId {
                if @payee_customer_id
                  xml.BkPtyId @payee_customer_id
                else
                  xml.BkPtyId @payee_y_tunnus
                end
              }
            }
          }

          xml.DbtrAcct {
            xml.Id {
              xml.IBAN @payee_iban
            }
          }

          xml.DbtrAgt {
            xml.FinInstnId {
              xml.BIC @payee_bic
            }
          }

          xml.ChrgBr 'SLEV'
        }
      end
    end
  end
end
