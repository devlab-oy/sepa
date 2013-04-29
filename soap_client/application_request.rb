require 'nokogiri'
require 'openssl'
require 'base64'

class ApplicationRequest
  def initialize(private_key, cert, command)
    @private_key = OpenSSL::PKey::RSA.new File.read private_key
    @cert = OpenSSL::X509::Certificate.new File.read cert
  end

  def process_application_request
    # Load the application request from template
    f = File.open("xml_templates/application_request/download_file_list.xml")
    application_request = Nokogiri::XML(f)
    f.close

    # Change the customer id of the application request to Nordea's testing ID
    customer_id = application_request.at_css "CustomerId"
    customer_id.content = "11111111"

    # Set the command
    command = application_request.at_css "Command"
    command.content = "DownloadFileList"

    #Set the timestamp
    timestamp = application_request.at_css "Timestamp"
    timestamp.content = Time.now.iso8601

    # Set status
    status = application_request.at_css "Status"
    status.content = "NEW"

    # Set the environment
    environment = application_request.at_css "Environment"
    environment.content = "PRODUCTION"

    # Set the target id
    targetid = application_request.at_css "TargetId"
    targetid.content = "11111111A1"

    # Set compression
    compression = application_request.at_css "Compression"
    compression.content = "false"

    #Set the software id
    softwareid = application_request.at_css "SoftwareId"
    softwareid.content = "Sepa Transfer Library version 0.1"

    # Set the file type
    filetype = application_request.at_css "FileType"
    filetype.content = "HTMKTO"

    application_request
  end
end