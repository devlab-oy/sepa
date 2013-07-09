module Sepa
  # This class is able to handle GetUserInfo, DownloadFileList, DownloadFile responses and pass content
  class XmlParser
    attr_accessor :timestamp, :responseCode, :encrypted, :compressed, :customerId, :responseText, :fileDescriptors, :userFiletypes, :content
    def initialize
      @content = ""
      @fileDescriptors = []
    end
    # Reads values from content field (xml file), returns a hash
    # Bank to customer statement
    def get_account_statement_content(file)

      if file == ""
        fail ArgumentError, "You didn't provide a file"

      elsif file != nil
        content = Nokogiri::XML(File.open(file))
        content.remove_namespaces!

        unless content == ""

          # To contain all needed values
          statement_content = {}

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
      end
      end
    end


    # Reads values from content field (xml file), returns a hash
    def get_debit_credit_notification_content(file)

      if file == ""
        fail ArgumentError, "You didn't provide a file"

      elsif file != nil
      content = Nokogiri::XML(File.open(file))
      content.remove_namespaces!

      unless content == ""

        notification_content = {}

        ##CASE Devlab suggested/selected fields

        # account iban
        notification_content[:account_iban] = content.at_css("Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Id/IBAN").content unless content.at_css("Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Id/IBAN") == nil

        # payer name
        notification_content[:account_owner] = content.at_css("Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Ownr/Nm").content unless content.at_css("Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Ownr/Nm") == nil

        # bic
        notification_content[:account_bic] = content.at_css("Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Svcr/FinInstnId/BIC").content unless content.at_css("Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Acct/Svcr/FinInstnId/BIC") == nil

        #Viitesiirtokentat
        # Notification entries
        notification_entries = []

        #txdtls_content = {}

        content.xpath("//Document/BkToCstmrDbtCdtNtfctn/Ntfctn/Ntry").each do |node|

          entry_content = {}

          # reference
          entry_content[:entry_reference] = node.at_css("NtryRef").content unless node.at_css("NtryRef") == nil
          # sum
          entry_content[:entry_sum] = node.at_css("Amt").content unless node.at_css("Amt") == nil
          # currency code
          entry_content[:entry_currency] = node.at_css("Amt")["Ccy"] unless node.at_css("Amt") == nil
          # entry date
          entry_content[:entry_booking_date] = node.at_css("BookgDt/Dt").content unless node.at_css("BookgDt/Dt") == nil
          # payment date
          entry_content[:entry_value_date] = node.at_css("ValDt/Dt").content unless node.at_css("ValDt/Dt") == nil

          # LOOP all txdtls
          txdtls_all = Array.new
          node.xpath("//NtryDtls/TxDtls").each do |nodejr|
          txdtls_content = Hash.new

            # TODO add check to transaction number
            # value before exchange
            txdtls_content[:gross_outgoing_value] = nodejr.at_css("AmtDtls/InstdAmt/Amt").content unless nodejr.at_css("AmtDtls/InstdAmt/Amt") == nil
            # currency before exchange
            txdtls_content[:gross_outgoing_currency] = nodejr.at_css("AmtDtls/InstdAmt/Amt")["Ccy"] unless nodejr.at_css("AmtDtls/InstdAmt/Amt") == nil

            # exchange rate
            txdtls_content[:currency_exchange_rate] = nodejr.at_css("AmtDtls/InstdAmt/CcyXchg/XchgRate").content unless nodejr.at_css("AmtDtls/InstdAmt/CcyXchg/XchgRate") == nil

            # value after exchange
            txdtls_content[:value_post_exchange] = nodejr.at_css("AmtDtls/TxAmt/Amt").content unless nodejr.at_css("AmtDtls/TxAmt/Amt") == nil
            # currency after exchange
            txdtls_content[:currency_post_exchange] = nodejr.at_css("AmtDtls/TxAmt/Amt")["Ccy"] unless nodejr.at_css("AmtDtls/TxAmt/Amt") == nil

          txdtls_all<<txdtls_content unless txdtls_content[:gross_outgoing_currency] == txdtls_content[:currency_post_exchange]
          end
          entry_content[:txdtls] = txdtls_all
          # Add single notification entry to array
          notification_entries<<entry_content
        end
        # Add array to hash
        notification_content[:notification_entries] = notification_entries

        # Returns hash
        notification_content

      end
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
      kek = Array.new
      kek<<@fileDescriptors.select { |fd| fd.status == "NEW" }
      kek
    end

    def list_all_descriptors
      @fileDescriptors
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

      customerId = xml.at_css("CustomerId").content unless xml.at_css("CustomerId") == nil
      timestamp = xml.at_css("Timestamp").content unless xml.at_css("Timestamp") == nil
      responseCode = xml.at_css("ResponseCode").content unless xml.at_css("ResponseCode") == nil
      responseText = xml.at_css("ResponseText").content unless xml.at_css("ResponseText") == nil
      encrypted = xml.at_css("Encrypted").content unless xml.at_css("Encrypted").content == nil
      compressed = xml.at_css("Compressed").content unless xml.at_css("Compressed") == nil

      # Decode the content portion automatically so that it can be read
      @content = Base64.decode64(xml.at_css("Content").content) unless xml.at_css("Content") == nil
      #puts content unless content == ""

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

      end

      # FILETYPESERVICES
      # Initialize array
      self.userFiletypes = Array.new

      # Iterate all userfiletypes
      xml.xpath("//UserFileTypes/UserFileType").each do |ftype|
        uftype = Sepa::Userfiletype.new

        # Assign class attributes
        uftype.targetId = ftype.at_css("TargetId").content
        uftype.fileType = ftype.at_css("FileType").content
        uftype.fileTypeName = ftype.at_css("FileTypeName").content
        uftype.country = ftype.at_css("Country").content
        uftype.direction = ftype.at_css("Direction").content

        uftype.filetypeServices = Array.new

        # Iterate all filetypeservice
        ftype.xpath("./FileTypeServices/FileTypeService").each do |ftypes|

          newservice = Sepa::Filetypeservice.new
          newservice.serviceId = ftypes.at_css("ServiceId").content unless ftypes.at_css("ServiceId") == nil
          newservice.serviceIdOwnerName = ftypes.at_css("ServiceIdOwnerName").content unless ftypes.at_css("ServiceIdOwnerName") == nil
          newservice.serviceIdType = ftypes.at_css("ServiceType").content unless ftypes.at_css("ServiceType") == nil
          newservice.serviceIdText = ftypes.at_css("ServiceIdText").content unless ftypes.at_css("ServiceIdText") == nil

          # Add new service to container
          uftype.add_filetypeservice(newservice)

        end
        # Add userfiletype to container
        self.add_userfiletype(uftype)
      end
    end
  end
end