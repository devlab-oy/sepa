require 'nokogiri'
#parses everything from application response
reader = Nokogiri::XML::Reader(IO.read("ApplicationResponse_DownloadFileList.xml"))

reader.each do

  if reader.node_type != Nokogiri::XML::Reader::TYPE_END_ELEMENT
    stuff = reader.name
    puts "\n" + stuff + ": " unless stuff == "#text"
    puts "\n" + reader.value unless reader.value == nil
    #puts "\n" + reader.attribute_nodes
  end
end