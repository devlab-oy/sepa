class Applicationresponse

  require 'nokogiri'
  require 'openssl'
  require 'base64'
  
  attr_accessor :timestamp, :responseCode, :encrypted, :compressed, :customerId, :responseText
  #TODO needs crosschecking from other responses to complete attributes
  #for inner use
  signature,timestamp,responseCode,responseText,encrypted,compressed,customerId,content = ''
  fileDescriptors = []
  userFiletypes = []

  #get_tiliote_content, get_viiteaineisto_content for pupesoft minreq.
  #tempname
  def get_tiliote_content
    #DEBUG CONTENT
    content = Nokogiri::XML(File.open("xml_examples/content_053.xml"))
    content.remove_namespaces!
    #END DEBUG
    #payment id, account, payer_name, reference, sum, currency_code, 
    #exchange_rate, entry_date, payment_date

    unless content == ""

      tiliote_content = {}
      # Current account info
      tiliote_content[:account] = content.at_css("Acct/Id/IBAN").content
      tiliote_content[:ownername] = content.at_css("Acct/Ownr/Nm").content
      tiliote_content[:accounttype] = content.at_css("Tp/Cd").content
      tiliote_content[:accountcurrencycode] = content.at_css("Acct/Ccy").content
      tiliote_content[:statementid] = content.at_css("ElctrncSeqNb").content
      tiliote_content[:fromdate] = content.at_css("FrDtTm").content
      tiliote_content[:todate] = content.at_css("ToDtTm").content
      # Y-tunnus
      tiliote_content[:organizationid] = content.at_css("Acct/Ownr/Id/OrgId/Othr/Id").content
      # Parent account of the curent account
      tiliote_content[:relatedaccount] = content.at_css("RltdAcct/Id/IBAN").content
      tiliote_content[:relatedaccountcurrencycode] = content.at_css("RltdAcct/Ccy").content
      # Account entries
      tiliote_content[:totalentries] = content.at_css("TxsSummry/TtlNtries/NbOfNtries").content
      tiliote_content[:totalwithdrawals] = content.at_css("TxsSummry/TtlDbtNtries/NbOfNtries").content
      tiliote_content[:totaldeposits] = content.at_css("TxsSummry/TtlCdtNtries/NbOfNtries").content
      tiliote_content[:withdrawalssum] = content.at_css("TxsSummry/TtlDbtNtries/Sum").content
      tiliote_content[:depositssum] = content.at_css("TxsSummry/TtlCdtNtries/Sum").content
      #TODO
      #Looping of transactions
      transactions = []
      #content.xpath("//Document/BkToCstmrStmt/Ntfctn/Ntry") for 054
      content.xpath("//Document/BkToCstmrStmt/Stmt/Ntry").each do |node| 
        #puts node.to_s
        #if node.at_css("Amt").content != nil
        transaction_content = {}
        transaction_content[:amount] = node.at_css("Amt").content
        #transaction_content[:currency] = node.at_css("").content
        transaction_content[:messageid] = node.at_css("NtryDtls/Btch/MsgId").content unless node.at_css("NtryDtls/Btch/MsgId") == nil
        transaction_content[:paymentinfoid] = node.at_css("NtryDtls/Btch/PmtInfId").content unless node.at_css("NtryDtls/Btch/PmtInfId") == nil
        #transaction_content[] = node.at_css("").content
        #transaction_content[] = node.at_css("").content
        #transaction_content[] = node.at_css("").content
        #puts node.content
        puts "***********"
        puts transaction_content[:amount]
        puts "***********"
        transactions<<transaction_content
      #end
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
      puts "But its empty."
    end
  end

  #tempname
  def get_viiteaineisto_content

  end

  #add incoming descriptor to array
  def add_descriptor(fdesc)
    fileDescriptors<<fdesc
  end

  #add incoming userfiletype to array
  def add_userfiletype(ufiletype)
    userFiletypes<<ufiletype
  end

  #returns the full array of descriptors
  def list_new_descriptors
    #TODO only the ones which include keyword NEW
    #@fileDescriptors
  end

  def list_all_descriptors
    fileDescriptors
  end

  #returns the full array of userfiletypes
  def list_userfiletypes
    userFiletypes
  end
  
  #returns a specific descriptor
  def select_descriptor(fileRef)
    #TODO change to .select structure
    fileDescriptors.each do |fd|
      if fd.fileReference == fileRef
        #break out when found
        return fd
      end
    end
  end

  #reads response from bank and fills attribute values
  def create_classes_from_response(file)
  #TODO
  xml = Nokogiri::XML(File.open(file))

  #to avoid conflicting results
  xml.remove_namespaces!
  #class attributes timestamp,responseCode,responseText,encrypted,compressed,customerId,content
  #theoretically unused attributes
  customerId = xml.at_css("CustomerId").content
  timestamp = xml.at_css("Timestamp").content
  responseCode = xml.at_css("ResponseCode").content
  responseText = xml.at_css("ResponseText").content
  encrypted = xml.at_css("Encrypted").content
  compressed = xml.at_css("Compressed").content
  #mandatory for nordea responses
  content = Base64.decode64(xml.at_css("Content").content)

  #DEBUG OUTPUT
  #puts customerId
  #puts timestamp
  #puts responseCode
  #puts responseText
  #puts encrypted
  #puts compressed
  #puts content

  #TODO: loop it
  fdesc = Filedescriptor.new
  ftypes = Filetypeservice.new
  #TODO: loop it
  uftype = Userfiletype.new

  #optional for debugging
  #sig = Signature.new
  #sig.digestValue = xml.at_css("DigestValue").content
  #sig.signatureValue = xml.at_css("SignatureValue").content
  #sig.X509Certificate = xml.at_css("X509Certificate").content
  #sig.X509IssuerName = xml.at_css("X509IssuerName").content
  #signature = sig
  
  end
end

load 'signature.rb'
load 'filedescriptor.rb'
load 'filetypeservice.rb'
load 'userfiletype.rb'
lepa = Applicationresponse.new
lepa.create_classes_from_response("xml_examples/applicationresponsedownloadfile.xml")
lepa.get_tiliote_content