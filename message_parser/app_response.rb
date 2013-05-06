class Applicationresponse
# This class is able to handle GetUserInfo, DownloadFileList, DownloadFile responses and pass content
  require 'nokogiri'
  require 'openssl'
  require 'base64'
  
  attr_accessor :timestamp, :responseCode, :encrypted, :compressed, :customerId, :responseText, :fileDescriptors, :userFiletypes
  #for inner use
  #signature,timestamp,responseCode,responseText,encrypted,compressed,customerId,content = ''
  #fileDescriptors = Array.new
  #userFiletypes = []

  ##get_tiliote_content, get_viiteaineisto_content for pupesoft minreq.
  ##tempname
  # Reads values from content field, ideally returns a hash
  # Bank to customer statement
  #TODO change to take the xml as param for release version
  def get_tiliote_content
    #DEBUG CONTENT
    content = Nokogiri::XML(File.open("xml_examples/content_053.xml"))
    content.remove_namespaces!
    #END DEBUG
    #key attributes for tiliote --->
    #payment id, account, payer_name, reference, sum, currency_code, 
    #exchange_rate, entry_date, payment_date

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
      
      #TODO Identifioi ainakin seuraavat
      ##Arkistointitunnus
      ##Saajan tilinumero
      ##Maksupaiva
      ##Arvopaiva
      ##Saaja/Maksaja
      ##Viesti
      ##Maara(arvo)
      ##Tapahtumalaji (702, 705)
      ##Oma sisainen viite
      ##Maksajan viite
      ##IBAN tilinumero
      ##BIC koodi
      ##Maksajan tunniste
      ##SEPA arkistointitunnus

      # Current account info
      tiliote_content[:account] = content.at_css("Acct/Id/IBAN").content
      tiliote_content[:ownername] = content.at_css("Acct/Ownr/Nm").content
      tiliote_content[:accounttype] = content.at_css("Tp/Cd").content
      tiliote_content[:accountcurrencycode] = content.at_css("Acct/Ccy").content
      tiliote_content[:statementid] = content.at_css("ElctrncSeqNb").content
      tiliote_content[:fromdate] = content.at_css("FrDtTm").content
      tiliote_content[:todate] = content.at_css("ToDtTm").content
      
      # Organization id(Y-tunnus)
      tiliote_content[:organizationid] = content.at_css("Acct/Ownr/Id/OrgId/Othr/Id").content
      
      # Parent account of the current account
      tiliote_content[:relatedaccount] = content.at_css("RltdAcct/Id/IBAN").content
      tiliote_content[:relatedaccountcurrencycode] = content.at_css("RltdAcct/Ccy").content
      
      # Account entries
      tiliote_content[:totalentries] = content.at_css("TxsSummry/TtlNtries/NbOfNtries").content
      tiliote_content[:totalwithdrawals] = content.at_css("TxsSummry/TtlDbtNtries/NbOfNtries").content
      tiliote_content[:totaldeposits] = content.at_css("TxsSummry/TtlCdtNtries/NbOfNtries").content
      tiliote_content[:withdrawalssum] = content.at_css("TxsSummry/TtlDbtNtries/Sum").content
      tiliote_content[:depositssum] = content.at_css("TxsSummry/TtlCdtNtries/Sum").content
      
      # To contain each transaction listed in the content
      transactions = []
      
      content.xpath("//Document/BkToCstmrStmt/Stmt/Ntry").each do |node| 
        
        # To contain needed values of a single transaction
        transaction_content = {}
        
        transaction_content[:amount] = node.at_css("Amt").content
        transaction_content[:currency] = node.at_css("Amt")["Ccy"]
        transaction_content[:creditdebitindicator] = node.at_css("CdtDbtInd").content
        transaction_content[:messageid] = node.at_css("NtryDtls/Btch/MsgId").content unless node.at_css("NtryDtls/Btch/MsgId") == nil
        transaction_content[:paymentinfoid] = node.at_css("NtryDtls/Btch/PmtInfId").content unless node.at_css("NtryDtls/Btch/PmtInfId") == nil
        
        # Payment details, exchange rate, booked amounts (note: rate exists in two places)
        transaction_content[:incomingvalue] = node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt").content unless node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt") == nil
        transaction_content[:incomingcurrency] = node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt")["Ccy"] unless node.at_css("NtryDtls/TxDtls/AmtDtls/InstdAmt/Amt") == nil
        transaction_content[:bookedvalue] = node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/Amt").content unless node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/Amt") == nil
        transaction_content[:bookedcurrency] = node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/Amt")["Ccy"] unless node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/Amt") == nil
        transaction_content[:exchangerate] = node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/XchgRate").content unless node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/XchgRate") == nil
        transaction_content[:contractid] = node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/CtrctId").content unless node.at_css("NtryDtls/TxDtls/AmtDtls/CntrValAmt/CcyXchg/CtrctId") == nil
        
        #DEBUG MESSAGES
        puts "***********"
        puts transaction_content[:amount]
        puts transaction_content[:currency]
        puts transaction_content[:exchangerate]
        puts "***********"
        #END DEBUG
        
        # Push to array
        transactions<<transaction_content
      
      end

      #DEBUG
      puts "-----------"
      puts transactions.inspect
      puts "-----------"
      puts tiliote_content[:account]
      puts tiliote_content[:accounttype]
      puts tiliote_content[:statementid]
      puts tiliote_content[:fromdate]
      puts tiliote_content[:todate]
      puts tiliote_content[:ownername]

      puts tiliote_content[:accountcurrencycode]
      puts tiliote_content[:organizationid]

      puts tiliote_content[:relatedaccount]
      puts tiliote_content[:relatedaccountcurrencycode]
      #END DEBUG
   
    else
      puts "Content is empty."
    end
  end

  ##tempname, really debitcreditnotification
  # Reads values from content field, ideally returns a hash
  #TODO change to take the xml as param for release version
  def get_viiteaineisto_content
    #DEBUG CONTENT
    content = Nokogiri::XML(File.open("xml_examples/content_054.xml"))
    content.remove_namespaces!
    #END of DEBUG CONTENT
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
  def create_classes_from_response(file)
    # Open the xml file
    xml = Nokogiri::XML(File.open(file))

    # To help navigating the response xml
    xml.remove_namespaces!
    # Class attributes timestamp,responseCode,responseText,encrypted,compressed,customerId,content
    # theoretically unused attributes. Might serve some use internally.
    customerId = xml.at_css("CustomerId").content
    timestamp = xml.at_css("Timestamp").content
    responseCode = xml.at_css("ResponseCode").content
    responseText = xml.at_css("ResponseText").content
    encrypted = xml.at_css("Encrypted").content
    compressed = xml.at_css("Compressed").content
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
      fdesc = Filedescriptor.new
      
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
    uftype = Userfiletype.new
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
      
      newservice = Filetypeservice.new
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

#DEBUG
load 'signature.rb'
load 'filedescriptor.rb'
load 'filetypeservice.rb'
load 'userfiletype.rb'
lepa = Applicationresponse.new
# Comment 2 out of 3 to debug reader with different types of responses
#lepa.create_classes_from_response("xml_examples/applicationresponsedownloadfile.xml")
#lepa.create_classes_from_response("xml_examples/ApplicationResponse_DownloadFileList.xml")
lepa.create_classes_from_response("xml_examples/ApplicationResponse_GetUserInfo.xml")
# To test content attribute passing
lepa.get_tiliote_content
#END DEBUG