require 'nokogiri'
require 'openssl'
require 'base64'
require 'time'

class ApplicationRequest
  def initialize(params)
    @private_key = OpenSSL::PKey::RSA.new File.read params[:private_key]
    @cert = OpenSSL::X509::Certificate.new File.read params[:cert]
    @command = params[:command]
    @customer_id = params[:customer_id]
    @status = params[:status]
    @target_id = params[:target_id]
    @file_type = params[:file_type]
  end

  def get_as_base64
    ar = sign
    Base64.encode64(ar.to_xml)
  end

  def get_as_xml
    ar = sign
  end

  private

  def load
    case @command
    when 'download_file_list'
      path = 'xml_templates/application_request/download_file_list.xml'
    else
      puts 'Could not load application request template because command was unrecognised.'
      return nil
    end

    f = File.open(path)
    ar = Nokogiri::XML(f)
    f.close

    ar
  end

  def process
    ar = load

    case @command
    when 'download_file_list'
      # Change the customer id of the application request to Nordea's testing ID
      customer_id = ar.at_css "CustomerId"
      customer_id.content = @customer_id
    
      # Set the command
      command = ar.at_css "Command"
      command.content = "DownloadFileList"
    
      #Set the timestamp
      timestamp = ar.at_css "Timestamp"
      timestamp.content = Time.now.iso8601
      
      # Set status
      status = ar.at_css "Status"
      status.content = @status
      
      # Set the environment
      environment = ar.at_css "Environment"
      environment.content = "PRODUCTION"
      
      # Set the target id
      targetid = ar.at_css "TargetId"
      targetid.content = @target_id
      
      # Set compression
      compression = ar.at_css "Compression"
      compression.content = "false"
      
      #Set the software id
      softwareid = ar.at_css "SoftwareId"
      softwareid.content = "Sepa Transfer Library version 0.1"
      
      # Set the file type
      filetype = ar.at_css "FileType"
      filetype.content = @file_type
    else
      puts 'Could not process application request because command was unrecognised.'
      return nil
    end

    ar
  end

  def sign
    ar = process

    #Remove signature element from application request for hashing
    signature = ar.xpath("//dsig:Signature", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#')
    signature.remove
  
    #Take digest from application request
    sha1 = OpenSSL::Digest::SHA1.new
    digestbin = sha1.digest(ar.canonicalize(mode=Nokogiri::XML::XML_C14N_1_0,inclusive_namespaces=nil,with_comments=false))
    digest = Base64.encode64(digestbin)
  
    # Add the signature
    ar.root.add_child(signature)
  
    # Insert digest to correct place
    ar_digest = ar.xpath(".//dsig:DigestValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
    ar_digest.content = digest.gsub(/\s+/, "")
  
    # Sign Signed info element
    signed_info = ar.xpath(".//dsig:SignedInfo", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
    signed_info_canon = signed_info.canonicalize(mode=Nokogiri::XML::XML_C14N_1_0,inclusive_namespaces=nil,with_comments=false)
    digest_sign = OpenSSL::Digest::SHA1.new
    signed_info_signature = @private_key.sign(digest_sign, signed_info_canon)
    signature_base64 = Base64.encode64(signed_info_signature)
  
    #Add the base64 coded signature to the signature element
    signature_node = ar.xpath(".//dsig:SignatureValue", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
    signature_node.content = signature_base64.gsub(/\s+/, "")
  
    #Format the certificate and add the it to the certificate element
    cert_formatted = @cert.to_s.split('-----BEGIN CERTIFICATE-----')[1].split('-----END CERTIFICATE-----')[0].gsub(/\s+/, "")
    cert_node = ar.xpath(".//dsig:X509Certificate", 'dsig' => 'http://www.w3.org/2000/09/xmldsig#').first
    cert_node.content = cert_formatted

    ar
  end
end
