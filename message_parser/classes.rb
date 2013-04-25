class Filedescriptor
  
  attr_accessor :fileReference, :targetId, :serviceId, :serviceIdOwnerName, :fileType, :fileTimestamp, :status

	@fileReference
	@targetId
	@serviceId
	@serviceIdOwnerName
	@fileType
	@fileTimestamp
  @status

end

class Applicationresponse

  require 'nokogiri'
  require 'openssl'
  require 'base64'
  
  attr_accessor :timestamp, :responseCode, :encrypted, :compressed
  #TODO needs crosschecking from other responses to complete attributes
  @fileDescriptors = []
  @signature
  @timestamp
  @responseCode
  @encrypted
  @compressed
  #add incoming descriptor to array
  def add_descriptor(Filedescriptor)
    @fileDescriptors<<Filedescriptor
  end

  #returns a specific descriptor
  def select_descriptor(fileRef)
    @fileDescriptors.each do |fd|
      if fd.fileReference == fileRef
        fd
      end
    end
  end

  #reads response from bank and fills attribute values
  def create(xmlfile)
  #TODO
  end

end

class Signature

  attr_accessor :digestValue, :signatureValue, :X509Certificate, :X509IssuerName
  
  @digestValue
  @signatureValue
  @X509Certificate
  @X509IssuerName
 
end