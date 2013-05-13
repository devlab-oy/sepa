require_relative 'filedescriptor'
require_relative 'filetypeservice'
require_relative 'signature'
require_relative 'userfiletype'
module Sepa
  class ApplicationResponse
    # This class is able to handle GetUserInfo, DownloadFileList, DownloadFile responses and pass content
    attr_accessor :timestamp, :responseCode, :encrypted, :compressed, :customerId, :responseText, :fileDescriptors, :userFiletypes
    
    def initialize
    end

    # Reads values from content field (xml file), returns a hash
    # Bank to customer statement
    def get_account_statement_content(file)

      content = Nokogiri::XML(File.open(file))
      content.remove_namespaces!

      unless content == ""

        # To contain all needed values
        statement_content = {}

        # Full fields of 053 account statement

        # Group header
        #content.at_css("Document/BkToCstmrStmt/GrpHdr/MsgId")
        #content.at_css("Document/BkToCstmrStmt/GrpHdr/CreDtTm")

        # Statement
        #content.at_css("Document/BkToCstmrStmt/Stmt/Id")
        #content.at_css("Document/BkToCstmrStmt/Stmt/ElctrncSeqNb")
        #content.at_css("Document/BkToCstmrStmt/Stmt/LglSeqNb")
        #content.at_css("Document/BkToCstmrStmt/Stmt/CreDtTm")

        # Booking date
        #content.at_css("Document/BkToCstmrStmt/Stmt/FrToDt/FrDtTm")
        #content.at_css("Document/BkToCstmrStmt/Stmt/FrToDt/ToDtTm")

        # Account
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Id/IBAN")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Nm")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Tp/Cd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ccy")

        # Owner
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/Nm")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/PstlAdr/StrNm")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/PstlAdldgNb")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/PstlAdr/PstCd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/PstlAdr/TwnNm")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/PstlAdr/Ctry")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/Id/OrgId/Othr/Id")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/Id/OrgId/Othr/SchmeNm/Cd")

        # BIC
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Svcr/FinInstnId/BIC")

        # Related account, not used with single account statement
        #content.at_css("Document/BkToCstmrStmt/Stmt/RltdAcct/Id/IBAN")
        #content.at_css("Document/BkToCstmrStmt/Stmt/RltdAcct/Ccy")

        # Interest
        #content.at_css("Document/BkToCstmrStmt/Stmt/Intrst/Tp/Cd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Intrst/Rate/Tp/Othr")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Intrst/Rate/VldtyRg")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Intrst/Rate/VldtyRg/Amt/FrToAmt/FrAmt/BdryAmt")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Intrst/Rate/VldtyRg/Amt/FrToAmt/FrAmt/Incl")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Intrst/Rate/VldtyRg/Amt/FrToAmt/ToAmt/BdryAmt")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Intrst/Rate/VldtyRg/Amt/FrToAmt/ToAmt/Incl")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Intrst/Rate/VldtyRg/CdtDbtInd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Intrst/Rate/VldtyRg/Ccy")

        # Balance, multiple occurrances
        #content.at_css("Document/BkToCstmrStmt/Stmt/Bal/Tp/CdOrPrtry/Cd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Bal/CdtLine/Incl")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Bal/CdtLine/Amt")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Bal/CdtLine/Amt")["Ccy"]
        #content.at_css("Document/BkToCstmrStmt/Stmt/Bal/Amt")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Bal/Amt")["Ccy"]
        #content.at_css("Document/BkToCstmrStmt/Stmt/Bal/CdDbtInd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Bal/Dt/Dt")

        # Transaction summary
        #content.at_css("Document/BkToCstmrStmt/Stmt/TxsSummry/TtlNtries/NbOfNtries")
        #content.at_css("Document/BkToCstmrStmt/Stmt/TxsSummry/TtlCdtNtries/NbOfNtries")
        #content.at_css("Document/BkToCstmrStmt/Stmt/TxsSummry/TtlCdtNtries/Sum")
        #content.at_css("Document/BkToCstmrStmt/Stmt/TxsSummry/TtlDbtNtries/NbOfNtries")
        #content.at_css("Document/BkToCstmrStmt/Stmt/TxsSummry/TtlDbtNtries/Sum")

        # Transaction entry, multiple occurrances
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryRef")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/Amt")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/Amt")["Ccy"]
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/CdDbtInd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/Sts")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/BookgDt/Dt")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/ValDt/Dt")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/AcctSvcrRef")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/BkTxCd/Domn/Cd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/BkTxCd/Domn/Fmly/Cd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/BkTxCd/Domn/Fmly/SubFmlyCd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/BkTxCd/Prtry/Cd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/BkTxCd/Prtry/Issr")
        # Transaction entry details
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/Btch/MsgId")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/Btch/PmtInfId")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/Btch/NbOfTxs")        
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/Refs/AcctSvcrRef")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/Refs/InstrId")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/Refs/TxId")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/Refs/EndToEndId")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt")["Ccy"]
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/Amt")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/Amt")["Ccy"]
        # Currency exchange
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/SrcCcy")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/TrgtCcy")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/UnitCcy")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/XchgRate")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/CtrctId")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/QtnDt")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/Amt")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/Amt")["Ccy"]
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/SrcCcy")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/TrgtCcy")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/UnitCcy")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/XchgRate")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/CtrcId")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/QtnDt")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/BkTxCd/Domn/Cd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/BkTxCd/Domn/Fmly/Cd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/BkTxCd/Domn/Fmly/SubFmlyCd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/BkTxCd/Prtry/Cd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/BkTxCd/Prtry/Issr")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/Chrgs/Amt")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/Chrgs/Amt")["Ccy"]
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/Chrgs/Tp/Cd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/Purp/Cd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdPties/Cdtr/Nm")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdPties/Cdtr/PstlAdr/Ctry")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdPties/Cdtr/PstlAdr/AdrLine")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdPties/Cdtr/CtryOfRes")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdPties/Dbtr/Nm")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdPties/Dbtr/Id/OrgId/Othr/Id")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdPties/Dbtr/Id/OrgId/Othr/Id/SchmeNm/Cd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdPties/UltmtDbtr/Nm")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdPties/UltmtDbtr/Id/OrgId/Othr/Id")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdPties/UltmtDbtr/Id/OrgId/Othr/SchmeNm")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdPties/CdtrAcct/Id/Othr/Id")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdPties/CdtrAcct/Id/IBAN")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdPties/CdtrAcct/Id/Othr/SchmeNm/Cd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdPties/CdtrAcct/Tp/Prtry")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdQties/Qty/Unit")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdAgts/DbtrAgt/FinInstId")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RmtInf/Strd/CdtrRefInf/Tp/CdOrPrtry/Cd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RmtInf/Strd/CdtrRefInf/Tp/Issr")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RmtInf/Strd/CdtrRefInf/Ref")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RmtInf/Strd/RfrdDocInf/Tp/CdOrPrtry/Cd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RmtInf/Strd/RfrdDocInf/Nb")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RmtInf/Strd/RfrdDocAmt/RmtdAmt")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RmtInf/Strd/RfrdDocAmt/RmtdAmt")["Ccy"]
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RmtInf/Strd/Invcee/Id/OrgId/Othr/Id")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RmtInf/Ustrd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/TxDtls/RltdDts/AccptncDtTm")
        
        # END full fields of 053 account statement

        # Selected fields

        ##CASE Devlab selected fields
        # Booking date
        statement_content[:bookingdatefrom] = content.at_css("Document/BkToCstmrStmt/Stmt/FrToDt/FrDtTm").content unless content.at_css("Document/BkToCstmrStmt/Stmt/FrToDt/FrDtTm") == nil
        statement_content[:bookingdateto] = content.at_css("Document/BkToCstmrStmt/Stmt/FrToDt/ToDtTm").content unless content.at_css("Document/BkToCstmrStmt/Stmt/FrToDt/ToDtTm") == nil

        # Account
        statement_content[:owneracctiban] = content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Id/IBAN").content unless content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Id/IBAN") == nil
        statement_content[:owneracctccy] = content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ccy").content unless content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ccy") == nil
        statement_content[:owneraccttype] = content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Nm").content unless content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Nm") == nil

        # Owner
        statement_content[:acctownername] = content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/Nm").content unless content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/Nm") == nil
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/PstlAdr/StrNm")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/PstlAdldgNb")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/PstlAdr/PstCd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/PstlAdr/TwnNm")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/PstlAdr/Ctry")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/Id/OrgId/Othr/Id")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/Id/OrgId/Othr/SchmeNm/Cd")

        # BIC
        statement_content[:owneracctbic] = content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Svcr/FinInstnId/BIC").content unless content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Svcr/FinInstnId/BIC").content == nil

        # To contain each transaction listed in the content
        transactions = []

        content.xpath("//Document/BkToCstmrStmt/Stmt/Ntry").each do |node|
          
          # To contain the values of a single transaction
          transaction_content = {}

          ##CASE Devlab selected fields
          ##Arkistointitunnus
          transaction_content[:acctsvcrref] = node.at_css("NtryDtls/TxDtls/Refs/AcctSvcrRef").content unless node.at_css("NtryDtls/TxDtls/Refs/AcctSvcrRef") == nil
          ##Saajan tilinumero
          transaction_content[:crdtiban] = node.at_css("NtryDtls/TxDtls/RltdPties/CdtrAcct/Id/IBAN").content unless node.at_css("NtryDtls/TxDtls/RltdPties/CdtrAcct/Id/IBAN") == nil
          ##Maksupaiva
          transaction_content[:bookingdate] = node.at_css("BookgDt/Dt").content unless node.at_css("BookgDt/Dt") == nil
          ##Arvopaiva
          transaction_content[:valuedate] = node.at_css("ValDt/Dt").content unless node.at_css("ValDt/Dt") == nil
          ##Saaja/Maksaja
          transaction_content[:crdtname] = node.at_css("NtryDtls/TxDtls/RltdPties/Cdtr/Nm").content unless node.at_css("NtryDtls/TxDtls/RltdPties/Cdtr/Nm") == nil
          ##Viesti
          transaction_content[:message] = node.at_css("NtryDtls/TxDtls/RmtInf/Ustrd").content unless node.at_css("NtryDtls/TxDtls/RmtInf/Ustrd") == nil
          ##Maara sisaantuleva(arvo)
          transaction_content[:incamt] = node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt").content unless node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt") == nil
          ##Valuutta sisaantuleva
          transaction_content[:incccy] = node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt")["Ccy"] unless node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt") == nil
          ##Maara kirjanpidollinen(arvo)
          transaction_content[:bkdamt] = node.at_css("NtryDtls/TxDtls/AmtDtls/TxAmt/Amt").content unless node.at_css("NtryDtls/TxDtls/AmtDtls/TxAmt/Amt") == nil
          ##Valuutta kirjanpidollinen
          transaction_content[:bkdccy] = node.at_css("NtryDtls/TxDtls/AmtDtls/TxAmt/Amt")["Ccy"] unless node.at_css("NtryDtls/TxDtls/AmtDtls/TxAmt/Amt") == nil
          ##Tapahtumalaji (702, 705)
          transaction_content[:trnscttype] = node.at_css("BkTxCd/Prtry/Cd").content unless node.at_css("BkTxCd/Prtry/Cd") == nil
          ##Tapahtumien maara
          transaction_content[:trnsctcnt] = node.at_css("NtryDtls/Btch/NbOfTxs").content unless node.at_css("NtryDtls/Btch/NbOfTxs") == nil
          ##Oma sisainen viite
          transaction_content[:internalid] = node.at_css("NtryDtls/Btch/PmtInfId").content unless node.at_css("NtryDtls/Btch/PmtInfId") == nil
          ##Maksajan viite
          transaction_content[:instrid] = node.at_css("NtryDtls/TxDtls/Refs/InstrId").content unless node.at_css("NtryDtls/TxDtls/Refs/InstrId") == nil
          ##IBAN tilinumero == saajan tilinumero?
          #transaction_content[:crdtiban] = node.at_css("NtryDtls/TxDtls/RltdPties/CdtrAcct/Id/IBAN").content
          ##BIC koodi (saaja)
          transaction_content[:crdtbin] = node.at_css("NtryDtls/TxDtls/RltdAgts/DbtrAgt/FinInstId").content unless node.at_css("NtryDtls/TxDtls/RltdAgts/DbtrAgt/FinInstId") == nil
          ##Maksajan tunniste
          transaction_content[:crdtid] = node.at_css("NtryDtls/TxDtls/RltdPties/CdtrAcct/Id/Othr/Id").content unless node.at_css("NtryDtls/TxDtls/RltdPties/CdtrAcct/Id/Othr/Id") == nil
          ##SEPA arkistointitunnus
          transaction_content[:sepabookingid] = node.at_css("AcctSvcrRef").content unless node.at_css("AcctSvcrRef") == nil

          # Push to array
          transactions<<transaction_content

        end

        statement_content[:transactions] = transactions

        # Returns hash
        statement_content
      else
        # No other kind of error handling implemented yet
        puts "Content is empty."
      end
    end

    
    # Reads values from content field (xml file), returns a hash
    def get_debit_credit_notification_content(file)

      content = Nokogiri::XML(File.open(file))
      content.remove_namespaces!

      unless content == ""

        notification_content = {}

        # 054 DebitCreditNotification fields, not fully checked if all are needed or that all required ones are included

        # Group header
        #Document/BkToCstmrDbtCdtNtfctn/GrpHdr/MsgId
        #Document/BkToCstmrDbtCdtNtfctn/GrpHdr/CreDtTm

        # Message receipt
        #Document/BkToCstmrDbtCdtNtfctn/GrpHdr/MsgMsgRcpt/Id/OrgId/Othr/Id
        #Document/BkToCstmrDbtCdtNtfctn/GrpHdr/MsgMsgRcpt/Id/OrgId/Othr/SchmeNm/Cd
        #Document/BkToCstmrDbtCdtNtfctn/GrpHdr/AddtlInf

        # Notification info, accounts, transaction summary
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Id
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/ElctrncSeqNb
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/CreDtTm
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Id/IBAN
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Tp/Cd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Ccy
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Nm
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Ownr/Nm
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Ownr/Id/OrgId/Othr/Id
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Ownr/Id/OrgId/Othr/SchmeNm/Cd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Svcr/FinInstnId/BIC
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/TxsSummry/TtlNtries/NbOfNtries
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/TxsSummry/TtlNtries/Sum
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/TxsSummry/TtlNtries/TtlNetNtryAmt
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/TxsSummry/TtlNtries/CdDbtInd

        # Notification entries
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryRef
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/Amt
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/Amt["Ccy"]
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/CdDbtInd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/Sts
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/BookgDt/Dt
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/ValDt/Dt
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/AcctSvcrRef
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/BkTxCd/Domn/Cd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/BkTxCd/Domn/Fmly/Cd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/BkTxCd/Domn/Fmly/SubFmlyCd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/BkTxCd/Prtry/Cd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/BkTxCd/Prtry/Issr

        # Notification entry details
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/Btch/MsgId
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/Btch/PmtInfId
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/Btch/NbOfTxs
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/Btch/TtlAmt
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/Btch/TtlAmt["Ccy"]
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/Btch/CdtDbtInd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/Refs/AcctSvcrRef
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/Refs/InstrId
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/Refs/TxId
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/Refs/EndToEndId
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt["Ccy"]
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/InstdAmt/CcyXchg/SrcCcy
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/InstdAmt/CcyXchg/TrgtCcy
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/InstdAmt/CcyXchg/UnitCcy
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/InstdAmt/CcyXchg/XchgRate
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/InstdAmt/CcyXchg/QtnDt
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/Amt
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/Amt["Ccy"]
        
        # Currency exchange, currencies, exchange rates
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/SrcCcy
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/TrgtCcy
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/UnitCcy
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/XchgRate
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/CtrctId
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/QtnDt
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/Amt
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/Amt["Ccy"]
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/SrcCcy
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/TrgtCcy
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/UnitCcy
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/XchgRate
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/CtrcId
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/QtnDt
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/BkTxCd/Domn/Cd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/BkTxCd/Domn/Fmly/Cd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/BkTxCd/Domn/Fmly/SubFmlyCd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/BkTxCd/Prtry/Cd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/BkTxCd/Prtry/Issr
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/Chrgs/Amt
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/Chrgs/Amt["Ccy"]
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/Chrgs/Tp/Cd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/Purp/Cd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/Cdtr/Nm
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/Cdtr/PstlAdr/Ctry
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/Cdtr/PstlAdr/AdrLine
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/Cdtr/CtryOfRes
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/Dbtr/Nm
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/Dbtr/Id/OrgId/Othr/Id
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/Dbtr/Id/OrgId/Othr/Id/SchmeNm/Cd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/UltmtDbtr/Nm
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/UltmtDbtr/Id/OrgId/Othr/Id
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/UltmtDbtr/Id/OrgId/Othr/SchmeNm
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/CdtrAcct/Id/Othr/Id
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/CdtrAcct/Id/Othr/SchmeNm/Cd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/CdtrAcct/Tp/Prtry
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdQties/Qty/Unit
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdAgts/DbtrAgt/FinInstId
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/CdtrRefInf/Tp/CdOrPrtry/Cd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/CdtrRefInf/Tp/Issr
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/CdtrRefInf/Ref
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/RfrdDocInf/Tp/CdOrPrtry/Cd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/RfrdDocInf/Nb
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/RfrdDocAmt/RmtdAmt
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/RfrdDocAmt/RmtdAmt["Ccy"]
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/Invcee/Id/OrgId/Othr/Id
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Ustrd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RltdDts/AccptncDtTm

        # END of 054 fields

        ##CASE Devlab suggested/selected fields

        ##Suggested fields
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Id
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/ElctrncSeqNb
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/CreDtTm

        # account iban
        notification_content[:account_iban] = content.at_css("Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Id/IBAN").content unless content.at_css("Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Id/IBAN") == nil
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Tp/Cd
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Ccy
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Nm
        
        # payer name
        notification_content[:account_owner] = content.at_css("Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Ownr/Nm").content unless content.at_css("Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Ownr/Nm") == nil
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Ownr/Id/OrgId/Othr/Id
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Ownr/Id/OrgId/Othr/SchmeNm/Cd
        # bic
        notification_content[:account_bic] = content.at_css("Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Svcr/FinInstnId/BIC").content unless content.at_css("Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Svcr/FinInstnId/BIC") == nil
    
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/TxsSummry/TtlNtries/NbOfNtries
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/TxsSummry/TtlNtries/Sum
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/TxsSummry/TtlNtries/TtlNetNtryAmt
        #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/TxsSummry/TtlNtries/CdDbtInd

        #Viitesiirtokentat
        # payment id -- what is dis?

        # Notification entries
        notification_entries = []
        
        content.xpath("//Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry").each do |node|

          entry_content = {}

          # reference
          entry_content[:entry_reference] = node.at_css("NtryRef").content unless node.at_css("NtryRef") == nil 
          # sum
          entry_content[:entry_sum] = node.at_css("Amt").content unless node.at_css("Amt") == nil
          # currency code
          entry_content[:entry_currency] = node.at_css("Amt")["Ccy"] unless node.at_css("Amt") == nil
          #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/CdDbtInd
          #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/Sts
          # entry date
          entry_content[:entry_booking_date] = node.at_css("BookgDt/Dt").content unless node.at_css("BookgDt/Dt") == nil
          # payment date
          entry_content[:entry_value_date] = node.at_css("ValDt/Dt").content unless node.at_css("ValDt/Dt") == nil
          #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/AcctSvcrRef
          #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/BkTxCd/Domn/Cd
          #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/BkTxCd/Domn/Fmly/Cd
          #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/BkTxCd/Domn/Fmly/SubFmlyCd
          #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/BkTxCd/Prtry/Cd
          #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/BkTxCd/Prtry/Issr
          #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/CdtrRefInf/Ref
          # value / currency before exchange
          entry_content[:gross_outgoing_value] = node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt").content unless node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt") == nil
          entry_content[:gross_outgoing_currency] = node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt")["Ccy"] unless node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt") == nil
          #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/InstdAmt/CcyXchg/SrcCcy
          #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/InstdAmt
          #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/InstdAmt
          # exchange rate
          entry_content[:currency_exchange_rate] = node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/CcyXchg/XchgRate").content unless node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/CcyXchg/XchgRate") == nil
          #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/InstdAmt/CcyXchg/QtnDt
          # value / currency after exchange
          entry_content[:value_post_exchange] = node.at_css("NtryDtls/TxDtls/AmtDtls/TxAmt/Amt").content unless node.at_css("NtryDtls/TxDtls/AmtDtls/TxAmt/Amt") == nil
          entry_content[:currency_post_exchange] = node.at_css("NtryDtls/TxDtls/AmtDtls/TxAmt/Amt")["Ccy"] unless node.at_css("NtryDtls/TxDtls/AmtDtls/TxAmt/Amt") == nil

          # Alternatively, exchange rate
          #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/XchgRate
          #Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/XchgRate

          # Add single notification entry to array
          notification_entries<<entry_content
        end
        # Add array to hash
        notification_content[:notification_entries] = notification_entries

        # Returns hash
        notification_content
      else
        puts "Content is empty."
      end

    end

    # Add incoming descriptor to array
    def add_descriptor(fdesc)
      fileDescriptors<<fdesc
    end

    # Add incoming userfiletype to the array
    def add_userfiletype(ufiletype)
      userFiletypes<<ufiletype
    end

    # Returns an array of file descriptors
    def list_new_descriptors
      # Lists NEW (not already downloaded) files only (as filedescriptor objects)
      fileDescriptors.select { |fd| fd.status == "NEW" }
    end

    def list_all_descriptors
      fileDescriptors
    end

    # Returns the full array list of userfiletypes in the response
    def list_userfiletypes
      userFiletypes
    end

    # Returns a specific descriptor matching the file reference
    def select_descriptor(fileRef)
      fileDescriptors.select { |fd| fd.fileReference == fileRef }
    end

    # Reads response xml from bank and fills attribute values
    def animate_response(file)
      # Open the xml file
      xml = Nokogiri::XML(File.open(file))

      # To help navigating the response xml
      xml.remove_namespaces!
      # Class attributes timestamp,responseCode,responseText,encrypted,compressed,customerId,content
      # theoretically unused attributes. Might serve some use internally.
      customerId = xml.at_css("CustomerId").content unless xml.at_css("CustomerId") == nil
      timestamp = xml.at_css("Timestamp").content unless xml.at_css("Timestamp") == nil
      responseCode = xml.at_css("ResponseCode").content unless xml.at_css("ResponseCode") == nil
      responseText = xml.at_css("ResponseText").content unless xml.at_css("ResponseText") == nil
      encrypted = xml.at_css("Encrypted").content unless xml.at_css("Encrypted").content == nil
      compressed = xml.at_css("Compressed").content unless xml.at_css("Compressed") == nil
      # Mandatory for nordea responses
      # Decode the content portion automatically so that it can be read
      content = Base64.decode64(xml.at_css("Content").content) unless xml.at_css("Content") == nil
      puts content unless content == ""
      #DEBUG OUTPUT
      #puts customerId
      #puts timestamp
      #puts responseCode
      #puts responseText
      #puts encrypted
      #puts compressed
      #puts content
      #END DEBUG

      # FILEDESCRIPTORS
      # Initialize array
      self.fileDescriptors = Array.new

      # Iterate all descriptors
      xml.xpath("//FileDescriptors/FileDescriptor").each do |desc|
        # Initialize
        fdesc = Sepa::Filedescriptor.new

        # Assigning class attributes
        fdesc.fileReference = desc.at_css("FileReference").content
        fdesc.targetId = desc.at_css("TargetId").content
        fdesc.serviceId = desc.at_css("ServiceId").content
        fdesc.serviceIdOwnerName = desc.at_css("ServiceIdOwnerName").content
        fdesc.fileType = desc.at_css("FileType").content
        fdesc.fileTimestamp = desc.at_css("FileTimestamp").content
        fdesc.status = desc.at_css("Status").content

        # Add to array
        self.add_descriptor(fdesc)

        #DEBUG
        #puts fdesc.fileReference
        #puts fdesc.targetId
        #puts fdesc.serviceId
        #puts fdesc.serviceIdOwnerName
        #puts fdesc.fileType
        #puts fdesc.fileTimestamp
        #puts fdesc.status
        #END DEBUG
      end

      #DEBUG
      puts "Listing full descriptor count  ------------------------"
      puts self.list_all_descriptors.count
      puts "Listing full descriptor count  ------------------------"
      #END DEBUG

      # FILETYPESERVICES
      # Initialize array
      self.userFiletypes = Array.new

      # Iterate all userfiletypes
      xml.xpath("//UserFileTypes/UserFileType").each do |ftype|
        uftype = Sepa::Userfiletype.new
        puts "I was at userfiletypes"

        # Assign class attributes
        uftype.targetId = ftype.at_css("TargetId").content
        uftype.fileType = ftype.at_css("FileType").content
        uftype.fileTypeName = ftype.at_css("FileTypeName").content
        uftype.country = ftype.at_css("Country").content
        uftype.direction = ftype.at_css("Direction").content

        uftype.filetypeServices = Array.new

        #DEBUG
        puts uftype.targetId
        puts uftype.fileType
        puts uftype.fileTypeName
        puts uftype.country
        puts uftype.direction
        #END DEBUG

        # Iterate all filetypeservice
        ftype.xpath("./FileTypeServices/FileTypeService").each do |ftypes|

          #DEBUG
          #puts "I was at filetypeservice WOHOO"
          #END DEBUG

          newservice = Sepa::Filetypeservice.new
          newservice.serviceId = ftypes.at_css("ServiceId").content unless ftypes.at_css("ServiceId") == nil
          newservice.serviceIdOwnerName = ftypes.at_css("ServiceIdOwnerName").content unless ftypes.at_css("ServiceIdOwnerName") == nil
          newservice.serviceIdType = ftypes.at_css("ServiceType").content unless ftypes.at_css("ServiceType") == nil
          newservice.serviceIdText = ftypes.at_css("ServiceIdText").content unless ftypes.at_css("ServiceIdText") == nil

          # Add new service to container
          uftype.add_filetypeservice(newservice)

          #DEBUG
          #puts "FTYPES -----------------------"
          #puts uftype.get_filetypeservices.count
          #puts "FTYPES -----------------------"
          #END DEBUG
        end
        # Add userfiletype to container
        self.add_userfiletype(uftype)
      end

      #DEBUG
      puts "Inspect the first object ---------------" unless self.userFiletypes.count < 1
      puts self.userFiletypes[0].get_filetypeservices.inspect unless self.userFiletypes.count < 1
      puts "Inspect the first object ---------------" unless self.userFiletypes.count < 1
      #END DEBUG

      #Optional for debugging signature attribute values
      #DEBUG
      #sig = Signature.new
      #sig.digestValue = xml.at_css("DigestValue").content
      #sig.signatureValue = xml.at_css("SignatureValue").content
      #sig.X509Certificate = xml.at_css("X509Certificate").content
      #sig.X509IssuerName = xml.at_css("X509IssuerName").content
      #signature = sig
      #END DEBUG

    end
  end
end