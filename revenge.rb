#PLEASE NOTE:
#the following is
#_pseudo-like code_
#classes/methods only to define structure, not necessarily implemented like this

class Transformer
require 'nokogiri'

	def fill_xml
	#parses to xml TODO: from objects or attributes, through REST API?
	end

	def read_xml
	#parses from xml to json messages
	end

  def canonicalization(xml_file)
  	#NOTES:
  	#to canonicalize outgoing xml
  	# xmlns:ec="http://www.w3.org/2001/10/xml-exc-c14n#"
    # targetNamespace="http://www.w3.org/2001/10/xml-exc-c14n#"

    #following for test purposes
    def test_cl4n_node
    	xml = '<a><b><c></c></b></a>'
    	doc = Nokogiri.XML xml
    	cl4n = doc.at_xpath('//b').canonicalize
    	assert_equal '<b><c></c></b>', cl4n
    end
  end
end 

class Inspector
require 'nokogiri'
	@counter = 1
	def check_xml_against_schema(xml_file, schema_file)
	#checks validity, required fields etc

		xsd = Nokogiri::XML::Schema(File.read(schema_file))
  	doc = Nokogiri::XML(File.read(xml_file))

  	xsd.validate(doc).each do |error|
    	puts error.message << ", on check #{@counter} - fail"
    else
    	puts "Check #{@counter} - pass"
    	@counter++
  	end
	end

end

class Secretive
require 'openssl'
	#NOTES&TODO:
	#prepared signature to be used with anything
	#defined private key (type)
	#defined public key (type)
	#public key of the party that is sending material

	def encrypt
		#TODO: check certicate type
		#password is to secure local keyfile

		#NOTES:
		#key2 = OpenSSL::PKey::RSA.new File.read 'private_key.pem'
		#key2.public?
		#key3 = OpenSSL::PKey::RSA.new File.read 'public_key.pem'
		#key3.private? # => false

		keypair = OpenSSL::PKey::RSA.new(File.read("DEFINE LOCATION.pem"), password)
		
		#NOTES:
		#can only be decrypted with public key
		#private_encrypted = keypair.private_encrypt 'public_document'
		
		#can only be decrypted with private key
		#public_enrypted = keypair.public_encrypt 'secret_document'

	end

	def decrypt
		
		#NOTES: opposite key to decrypt
		#secret_document = key.public_decrypt public_encrypted
		#public_document = key.private_decrypt private_encrypted

	end

	def add_signature
		cert = OpenSSL::X509::Certificate.new(File.read("DEFINE LOCATION.pem"))

		cert.issuer = name
		cert.sign key, OpenSSL::Digest::SHA1.new
		#file locations undefined
		open 'TESTINGFILE.pem', 'w' do |io| io.write cert.to_pem end
	end

	def confirm_signature
		#not sure if required, can extend add_signature if needed
	end

	def compare
		#not sure if required, can extend encrypt if needed
		#comparing hash?
	end

end