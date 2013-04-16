require 'nokogiri'
#Give source xml file as argument on command line, writes to same directory in file "m_testing_cano_results.xml"
xmldoc = Nokogiri::XML(File.read(ARGV[0]), nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS | Nokogiri::XML::ParseOptions::NOCDATA | Nokogiri::XML::ParseOptions::STRICT)
File.open("m_testing_cano_results.xml", 'w') {|f| f.write(xmldoc.to_xml)}
