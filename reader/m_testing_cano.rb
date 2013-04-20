require 'nokogiri'
#Give source xml file as argument on command line, writes to same directory in file "m_testing_cano_results.xml"
#xmldoc = Nokogiri::XML(File.read(ARGV[0]), nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS | Nokogiri::XML::ParseOptions::NOCDATA | Nokogiri::XML::ParseOptions::STRICT)
#xmldoc.canonicalize(mode=Nokogiri::XML::XML_C14N_1_0,inclusive_namespaces=nil,with_comments=false)
#File.open("m_testing_cano_results2.xml", 'w') {|f| f.write(xmldoc.to_xml)}

testdoc = Nokogiri::XML(File.read("soap_request_header_template.xml"), nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS | Nokogiri::XML::ParseOptions::NOCDATA | Nokogiri::XML::ParseOptions::STRICT)
testdoc.canonicalize(mode=Nokogiri::XML::XML_C14N_1_0,inclusive_namespaces=nil,with_comments=false)
File.open("result.xml", 'w') {|f| f.write(testdoc.to_xml)}