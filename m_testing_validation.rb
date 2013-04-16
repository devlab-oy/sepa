require 'nokogiri'

##This is a test validator

xsd = Nokogiri::XML::Schema(File.read("ApplicationResponse.xsd"))
doc = Nokogiri::XML(File.read("ApplicationResponse_DownloadFileList.xml"))

   xsd.validate(doc).each do |error|
     puts error.message
   end