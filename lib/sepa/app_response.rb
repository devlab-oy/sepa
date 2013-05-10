module Sepa
  class Applicationresponse
    # This class is able to handle GetUserInfo, DownloadFileList, DownloadFile responses and pass content
    #DEBUG
    require 'nokogiri'
    require 'openssl'
    require 'base64'
    #END DEBUG
    attr_accessor :timestamp, :responseCode, :encrypted, :compressed, :customerId, :responseText, :fileDescriptors, :userFiletypes
    
    # Reads values from content field (xml file), ideally returns a hash
    # Bank to customer statement
    def get_acctstmt_content(file)

      content = Nokogiri::XML(File.open(file))
      content.remove_namespaces!

      unless content == ""

        # To contain all needed values
        tiliote_content = {}

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
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/Btch/MsgId")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/Btch/PmtInfId")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Ntry/NtryDtls/Btch/NbOfTxs")
        ## Element can have multiple occurrences
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
        # Multiple elements on address line, at least 2
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

        # Group header
        #content.at_css("Document/BkToCstmrStmt/GrpHdr/MsgId")
        #content.at_css("Document/BkToCstmrStmt/GrpHdr/CreDtTm")

        # Statement
        #content.at_css("Document/BkToCstmrStmt/Stmt/Id")
        #content.at_css("Document/BkToCstmrStmt/Stmt/ElctrncSeqNb")
        #content.at_css("Document/BkToCstmrStmt/Stmt/LglSeqNb")
        #content.at_css("Document/BkToCstmrStmt/Stmt/CreDtTm")

        # Booking date
        tiliote_content[:bookingdatefrom] = content.at_css("Document/BkToCstmrStmt/Stmt/FrToDt/FrDtTm").content unless content.at_css("Document/BkToCstmrStmt/Stmt/FrToDt/FrDtTm") == nil
        tiliote_content[:bookingdateto] = content.at_css("Document/BkToCstmrStmt/Stmt/FrToDt/ToDtTm").content unless content.at_css("Document/BkToCstmrStmt/Stmt/FrToDt/ToDtTm") == nil

        # Account
        tiliote_content[:owneracctiban] = content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Id/IBAN").content unless content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Id/IBAN") == nil
        #tiliote_content[:] = content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Tp/Cd")
        tiliote_content[:owneracctccy] = content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ccy").content unless content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ccy") == nil
        tiliote_content[:owneraccttype] = content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Nm").content unless content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Nm") == nil

        # Owner
        tiliote_content[:acctownername] = content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/Nm").content unless content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/Nm") == nil
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/PstlAdr/StrNm")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/PstlAdldgNb")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/PstlAdr/PstCd")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/PstlAdr/TwnNm")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/PstlAdr/Ctry")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/Id/OrgId/Othr/Id")
        #content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Ownr/Id/OrgId/Othr/SchmeNm/Cd")

        # BIC
        tiliote_content[:owneracctbic] = content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Svcr/FinInstnId/BIC").content unless content.at_css("Document/BkToCstmrStmt/Stmt/Acct/Svcr/FinInstnId/BIC").content == nil

        # Current account info
        #tiliote_content[:ownername] = content.at_css("Acct/Ownr/Nm").content
        #tiliote_content[:account] = content.at_css("Acct/Id/IBAN").content
        #tiliote_content[:accounttype] = content.at_css("Tp/Cd").content
        #tiliote_content[:accountcurrencycode] = content.at_css("Acct/Ccy").content
        #tiliote_content[:statementid] = content.at_css("ElctrncSeqNb").content
        #tiliote_content[:fromdate] = content.at_css("FrDtTm").content
        #tiliote_content[:todate] = content.at_css("ToDtTm").content

        # Organization id(Y-tunnus)
        #tiliote_content[:organizationid] = content.at_css("Acct/Ownr/Id/OrgId/Othr/Id").content

        # Parent account of the current account
        #tiliote_content[:relatedaccount] = content.at_css("RltdAcct/Id/IBAN").content
        #tiliote_content[:relatedaccountcurrencycode] = content.at_css("RltdAcct/Ccy").content

        # Account entries
        #tiliote_content[:totalentries] = content.at_css("TxsSummry/TtlNtries/NbOfNtries").content
        #tiliote_content[:totalwithdrawals] = content.at_css("TxsSummry/TtlDbtNtries/NbOfNtries").content
        #tiliote_content[:totaldeposits] = content.at_css("TxsSummry/TtlCdtNtries/NbOfNtries").content
        #tiliote_content[:withdrawalssum] = content.at_css("TxsSummry/TtlDbtNtries/Sum").content
        #tiliote_content[:depositssum] = content.at_css("TxsSummry/TtlCdtNtries/Sum").content

        puts tiliote_content
        # To contain each transaction listed in the content
        transactions = []

        content.xpath("//Document/BkToCstmrStmt/Stmt/Ntry").each do |node|
          #puts node
          # To contain needed values of a single transaction
          transaction_content = {}

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
          ##IBAN tilinumero - saajan tilinumero?
          #transaction_content[:crdtiban] = node.at_css("NtryDtls/TxDtls/RltdPties/CdtrAcct/Id/IBAN").content
          ##BIC koodi (saaja)
          transaction_content[:crdtbin] = node.at_css("NtryDtls/TxDtls/RltdAgts/DbtrAgt/FinInstId").content unless node.at_css("NtryDtls/TxDtls/RltdAgts/DbtrAgt/FinInstId") == nil
          ##Maksajan tunniste
          transaction_content[:crdtid] = node.at_css("NtryDtls/TxDtls/RltdPties/CdtrAcct/Id/Othr/Id").content unless node.at_css("NtryDtls/TxDtls/RltdPties/CdtrAcct/Id/Othr/Id") == nil
          ##SEPA arkistointitunnus
          transaction_content[:sepabookingid] = node.at_css("AcctSvcrRef").content unless node.at_css("AcctSvcrRef") == nil
          #transaction_content[:amount] = node.at_css("Amt").content
          #transaction_content[:currency] = node.at_css("Amt")["Ccy"]
          #transaction_content[:creditdebitindicator] = node.at_css("CdtDbtInd").content
          #transaction_content[:messageid] = node.at_css("NtryDtls/Btch/MsgId").content unless node.at_css("NtryDtls/Btch/MsgId") == nil
          #transaction_content[:paymentinfoid] = node.at_css("NtryDtls/Btch/PmtInfId").content unless node.at_css("NtryDtls/Btch/PmtInfId") == nil

          # Payment details, exchange rate, booked amounts (note: rate exists in two places)
          #transaction_content[:incomingvalue] = node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt").content unless node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt") == nil
          #transaction_content[:incomingcurrency] = node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt")["Ccy"] unless node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt") == nil
          #transaction_content[:bookedvalue] = node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/Amt").content unless node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/Amt") == nil
          #transaction_content[:bookedcurrency] = node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/Amt")["Ccy"] unless node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/Amt") == nil
          #transaction_content[:exchangerate] = node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/XchgRate").content unless node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/XchgRate") == nil
          #transaction_content[:contractid] = node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/CtrctId").content unless node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/CtrctId") == nil

          #DEBUG MESSAGES
          #puts "***********"
          #puts transaction_content[:amount]
          #puts transaction_content[:currency]
          #puts transaction_content[:exchangerate]
          #puts "***********"
          #END DEBUG

          # Push to array
          transactions<<transaction_content

        end

        tiliote_content[:transactions] = transactions
        #DEBUG
        #puts "-----------"
        #puts transactions.inspect
        #puts "-----------"
        #puts tiliote_content[:account]
        #puts tiliote_content[:accounttype]
        #puts tiliote_content[:statementid]
        #puts tiliote_content[:fromdate]
        #puts tiliote_content[:todate]
        #puts tiliote_content[:ownername]

        #puts tiliote_content[:accountcurrencycode]
        #puts tiliote_content[:organizationid]

        #puts tiliote_content[:relatedaccount]
        #puts tiliote_content[:relatedaccountcurrencycode]
        #END DEBUG

        # Returns hash
        tiliote_content
      else
        puts "Content is empty."
      end
    end

    
    # Reads values from content field (xml file), ideally returns a hash
    def get_debitcreditnotification_content(file)

      content = Nokogiri::XML(File.open(file))
      content.remove_namespaces!

      unless content == ""

        viiteaineisto_content = {}

        #054 DebitCreditNotification paths, not fully checked if all are needed, quickly checked that all required ones are included

        # Group header
        #Document/BkToCstmrDbtCdtNtfcnt/GrpHdr/MsgId
        #Document/BkToCstmrDbtCdtNtfcnt/GrpHdr/CreDtTm

        # Message receipt
        #Document/BkToCstmrDbtCdtNtfcnt/GrpHdr/MsgMsgRcpt/Id/OrgId/Othr/Id
        #Document/BkToCstmrDbtCdtNtfcnt/GrpHdr/MsgMsgRcpt/Id/OrgId/Othr/SchmeNm/Cd
        #Document/BkToCstmrDbtCdtNtfcnt/GrpHdr/AddtlInf

        # Notification info, accounts, transaction summary
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Id
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/ElctrncSeqNb
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/CreDtTm
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Acct/Id/IBAN
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Acct/Tp/Cd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Acct/Ccy
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Acct/Nm
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Acct/Ownr/Nm
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Acct/Ownr/Id/OrgId/Othr/Id
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Acct/Ownr/Id/OrgId/Othr/SchmeNm/Cd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Acct/Svcr/FinInstnId/BIC
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/TxsSummry/TtlNtries/NbOfNtries
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/TxsSummry/TtlNtries/Sum
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/TxsSummry/TtlNtries/TtlNetNtryAmt
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/TxsSummry/TtlNtries/CdDbtInd

        # Notification entries
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryRef
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/Amt
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/Amt["Ccy"]
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/CdDbtInd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/Sts
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/BookgDt/Dt
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/ValDt/Dt
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/AcctSvcrRef
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/BkTxCd/Domn/Cd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/BkTxCd/Domn/Fmly/Cd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/BkTxCd/Domn/Fmly/SubFmlyCd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/BkTxCd/Prtry/Cd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/BkTxCd/Prtry/Issr

        # Notification entry details
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/Btch/MsgId
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/Btch/PmtInfId
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/Btch/NbOfTxs
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/Btch/TtlAmt
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/Btch/TtlAmt["Ccy"]
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/Btch/CdtDbtInd
        ## Element can have multiple occurrences
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/Refs/AcctSvcrRef
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/Refs/InstrId
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/Refs/TxId
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/Refs/EndToEndId
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt["Ccy"]
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/Amt
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/Amt["Ccy"]
        ## Currency exchange, currencies, exchange rates
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/SrcCcy
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/TrgtCcy
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/UnitCcy
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/XchgRate
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/CtrctId
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/TxAmt/CcyXchg/QtnDt
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/Amt
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/Amt["Ccy"]
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/SrcCcy
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/TrgtCcy
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/UnitCcy
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/XchgRate
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/CtrcId
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/QtnDt
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/BkTxCd/Domn/Cd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/BkTxCd/Domn/Fmly/Cd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/BkTxCd/Domn/Fmly/SubFmlyCd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/BkTxCd/Prtry/Cd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/BkTxCd/Prtry/Issr
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/Chrgs/Amt
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/Chrgs/Amt["Ccy"]
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/Chrgs/Tp/Cd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/Purp/Cd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/Cdtr/Nm
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/Cdtr/PstlAdr/Ctry
        ## Multiple elements on address line, at least 2
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/Cdtr/PstlAdr/AdrLine
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/Cdtr/CtryOfRes
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/Dbtr/Nm
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/Dbtr/Id/OrgId/Othr/Id
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/Dbtr/Id/OrgId/Othr/Id/SchmeNm/Cd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/UltmtDbtr/Nm
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/UltmtDbtr/Id/OrgId/Othr/Id
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/UltmtDbtr/Id/OrgId/Othr/SchmeNm
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/CdtrAcct/Id/Othr/Id
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/CdtrAcct/Id/Othr/SchmeNm/Cd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdPties/CdtrAcct/Tp/Prtry
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdQties/Qty/Unit
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdAgts/DbtrAgt/FinInstId
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/CdtrRefInf/Tp/CdOrPrtry/Cd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/CdtrRefInf/Tp/Issr
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/CdtrRefInf/Ref
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/RfrdDocInf/Tp/CdOrPrtry/Cd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/RfrdDocInf/Nb
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/RfrdDocAmt/RmtdAmt
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/RfrdDocAmt/RmtdAmt["Ccy"]
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Strd/Invcee/Id/OrgId/Othr/Id
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RmtInf/Ustrd
        #Document/BkToCstmrDbtCdtNtfcnt/Ntfctn/Ntry/NtryDtls/TxDtls/RltdDts/AccptncDtTm

        #TODO Listaa tarkeimmat kentat mita valintaan otetaan mukaan

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
      # Lists NEW (not already downloaded) files only
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
      puts "Inspect the first object ---------------"
      puts self.userFiletypes[0].get_filetypeservices.inspect
      puts "Inspect the first object ---------------"
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