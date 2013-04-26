class Filedescriptor
  
  attr_accessor :fileReference, :targetId, :serviceId, :serviceIdOwnerName, :fileType, :fileTimestamp, :status

  @fileReference
  @tSargetId
  @serviceId
  @serviceIdOwnerName
  @fileType
  @fileTimestamp
  @status

end

class Filetypeservice

  attr_accessor :serviceId, :serviceIdOwnerName, :serviceIdType, :serviceIdText

  @serviceId
  @serviceIdOwnerName
  @serviceIdType
  @serviceIdText

end

class Userfiletype

  attr_accessor :targetId, :fileType, :fileTypeName, :country, :direction

  @targetId
  @fileType
  @fileTypeName
  @country
  @direction
  @filetypeServices = []

  #add incoming filetypeservice to array
  def add_filetypeservice(Filetypeservice)
    @filetypeServices<<Filetypeservice 
  end

  #to get the full array instead of attr_accessor for easier adding of conditions
  def get_filetypeservices
    ftservices = Array.new
    filetypeServices.each do |ftservice|
      ftservices<<ftservice
    end
    ftservices
  end

end

class Applicationresponse

  require 'nokogiri'
  require 'openssl'
  require 'base64'
  
  attr_accessor :timestamp, :responseCode, :encrypted, :compressed, :customerId, :responseText
  #TODO needs crosschecking from other responses to complete attributes
  @fileDescriptors = []
  @signature
  @timestamp
  @responseCode
  @responseText
  @encrypted
  @compressed
  @customerId
  @userFiletypes = []

  #add incoming descriptor to array
  def add_descriptor(Filedescriptor)
    @fileDescriptors<<Filedescriptor
  end

  #add incoming userfiletype to array
  def add_userfiletype(Userfiletype)
    @userFiletypes<<Userfiletype
  end

  #returns a specific descriptor
  def select_descriptor(fileRef)
    @fileDescriptors.each do |fd|
      if fd.fileReference == fileRef
        #break out when found
        return fd
      end
    end
  end

  #reads response from bank and fills attribute values
  def create_classes_from_response(xmlfile)
  #TODO
  end

end

class Signature
  #this class is not really needed
  attr_accessor :digestValue, :signatureValue, :X509Certificate, :X509IssuerName
  
  @digestValue
  @signatureValue
  @X509Certificate
  @X509IssuerName
 
end
