class Applicationresponse

  require 'nokogiri'
  require 'openssl'
  require 'base64'
  
  attr_accessor :timestamp, :responseCode, :encrypted, :compressed, :customerId, :responseText, :fileDescriptors, :userFiletypes
  #TODO needs crosschecking from other responses to complete attributes
  #for inner use
  #signature,timestamp,responseCode,responseText,encrypted,compressed,customerId,content = ''
  #fileDescriptors = Array.new
  #userFiletypes = []

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
      # Parent account of the current account
      tiliote_content[:relatedaccount] = content.at_css("RltdAcct/Id/IBAN").content
      tiliote_content[:relatedaccountcurrencycode] = content.at_css("RltdAcct/Ccy").content
      # Account entries
      tiliote_content[:totalentries] = content.at_css("TxsSummry/TtlNtries/NbOfNtries").content
      tiliote_content[:totalwithdrawals] = content.at_css("TxsSummry/TtlDbtNtries/NbOfNtries").content
      tiliote_content[:totaldeposits] = content.at_css("TxsSummry/TtlCdtNtries/NbOfNtries").content
      tiliote_content[:withdrawalssum] = content.at_css("TxsSummry/TtlDbtNtries/Sum").content
      tiliote_content[:depositssum] = content.at_css("TxsSummry/TtlCdtNtries/Sum").content
      
      # For each transaction in the content
      transactions = []
      #content.xpath("//Document/BkToCstmrStmt/Ntfctn/Ntry") for 054
      content.xpath("//Document/BkToCstmrStmt/Stmt/Ntry").each do |node| 
        
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

  #tempname
  def get_viiteaineisto_content
    #DEBUG CONTENT
    content = Nokogiri::XML(File.open("xml_examples/content_053.xml"))
    content.remove_namespaces!
    #END of DEBUG CONTENT
    unless content = ""
    
      viiteaineisto_content = {}

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
    # Lists NEW files only
    fileDescriptors.select { |fd| fd.status == "NEW" }
  
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
    
    fileDescriptors.select { |fd| fd.fileReference == fileRef }
    
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
  content = Base64.decode64(xml.at_css("Content").content) unless xml.at_css("Content") == nil 

  #DEBUG OUTPUT
  #puts customerId
  #puts timestamp
  #puts responseCode
  #puts responseText
  #puts encrypted
  #puts compressed
  #puts content

  #TODO: loop it
  #farray = Array.new
  #FILEDESCRIPTORS
  # Initialize array
  self.fileDescriptors = Array.new
  
  xml.xpath("//FileDescriptors/FileDescriptor").each do |desc|
    fdesc = Filedescriptor.new
    #puts "HELLO --------------------------------------- CAT"
    #fileReference,targetId,serviceId,serviceIdOwnerName,fileType,fileTimestamp,status
    fdesc.fileReference = desc.at_css("FileReference").content
    fdesc.targetId = desc.at_css("TargetId").content
    fdesc.serviceId = desc.at_css("ServiceId").content
    fdesc.serviceIdOwnerName = desc.at_css("ServiceIdOwnerName").content
    fdesc.fileType = desc.at_css("FileType").content
    fdesc.fileTimestamp = desc.at_css("FileTimestamp").content
    fdesc.status = desc.at_css("Status").content
    #farray<<fdesc
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
  #puts farray.count
  
  puts "HI ------------------------"
  puts self.list_all_descriptors.count
  puts "BYE-------------------------"


  #FILETYPESERVICES
  # Initialize array
  self.userFiletypes = Array.new

  xml.xpath("//UserFileTypes/UserFileType").each do |ftype|
    uftype = Userfiletype.new
    puts "I was at userfiletypes"
    uftype.targetId = ftype.at_css("TargetId").content
    uftype.fileType = ftype.at_css("FileType").content
    uftype.fileTypeName = ftype.at_css("FileTypeName").content
    uftype.country = ftype.at_css("Country").content
    uftype.direction = ftype.at_css("Direction").content
    uftype.filetypeServices = Array.new
    
    puts uftype.targetId
    puts uftype.fileType
    puts uftype.fileTypeName
    puts uftype.country
    puts uftype.direction

    ftype.xpath("./FileTypeServices/FileTypeService").each do |ftypes|
      #DEBUG
      #puts "I was at filetypeservice WOHOO"
      #END DEBUG
      newservice = Filetypeservice.new
      newservice.serviceId = ftypes.at_css("ServiceId").content unless ftypes.at_css("ServiceId") == nil
      newservice.serviceIdOwnerName = ftypes.at_css("ServiceIdOwnerName").content unless ftypes.at_css("ServiceIdOwnerName") == nil
      newservice.serviceIdType = ftypes.at_css("ServiceType").content unless ftypes.at_css("ServiceType") == nil
      newservice.serviceIdText = ftypes.at_css("ServiceIdText").content unless ftypes.at_css("ServiceIdText") == nil

      uftype.add_filetypeservice(newservice)
      #DEBUG
      #puts "FTYPES -----------------------"
      #puts uftype.get_filetypeservices.count
      #puts "FTYPES -----------------------"
      #END DEBUG
    end
    self.add_userfiletype(uftype)
  end
  #DEBUG
  puts "Inspect the first object ---------------"
  puts self.userFiletypes[0].get_filetypeservices.inspect
  puts "Inspect the first object ---------------"
  #END DEBUG
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
# Comment 2 out of 3 to debug with different responses
#lepa.create_classes_from_response("xml_examples/applicationresponsedownloadfile.xml")
#lepa.create_classes_from_response("xml_examples/ApplicationResponse_DownloadFileList.xml")
lepa.create_classes_from_response("xml_examples/ApplicationResponse_GetUserInfo.xml")
# To test content passing
lepa.get_tiliote_content