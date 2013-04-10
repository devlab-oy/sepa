#PLEASE NOTE:
#the following is
#_pseudo-like code_
#classes/methods only to define structure, not necessarily implemented like this

class Transformer
  require 'nokogiri'

  def fill_xml
  #parses to xml TODO: from objects or attributes, through REST API?
  #NOTES:
  #Starts with using a predefined prefilled xml in the first iteration
  #what kinds of messages incoming in the final iteration?
  end

  def read_xml
  #NOTES:
  #parses reply from xml to json messages
  #requirements for final implementation?
  end

  def canonicalization(xml_file)
    #NOTES:
    #to canonicalize outgoing xml
    # xmlns:ec="http://www.w3.org/2001/10/xml-exc-c14n#"
    # targetNamespace="http://www.w3.org/2001/10/xml-exc-c14n#"
    #  Schema Definition:
    #
    #   #<?xml version="1.0" encoding="utf-8"?>
    #   #<!DOCTYPE schema
    #   #  PUBLIC "-//W3C//DTD XMLSchema 200102//EN" "http://www.w3.org/2001/XMLSchema.dtd"
    #   # [
    #   #   <!ATTLIST schema 
    #   #     xmlns:ec CDATA #FIXED 'http://www.w3.org/2001/10/xml-exc-c14n#'>
    #   #   <!ENTITY ec 'http://www.w3.org/2001/10/xml-exc-c14n#'> 
    #   #   <!ENTITY % p ''>
    #   #   <!ENTITY % s ''>
    #   #  ]>
    #
    #<schema xmlns="http://www.w3.org/2001/XMLSchema"
    #       xmlns:ec="http://www.w3.org/2001/10/xml-exc-c14n#"
    #          targetNamespace="http://www.w3.org/2001/10/xml-exc-c14n#"
    #          version="0.1" elementFormDefault="qualified">
    #
    #    <element name="InclusiveNamespaces"
    #             type="ec:InclusiveNamespaces"/>
    #    <complexType name="InclusiveNamespaces">
    #       <attribute name="PrefixList" type="NMTOKENS"/>
    #    </complexType>
    #  </schema>
    #  DTD:
    #  <!ELEMENT InclusiveNamespaces    EMPTY >
    #  <!ATTLIST InclusiveNamespaces
    #  PrefixList    NMTOKENS    #REQUIRED >

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
    #checks validity, required fields, parameters within given constraints etc

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
  #public key of the party that is receiving sent material

  def encrypt_content
  #TODO: check certicate type
  #password is to secure local keyfile with encryption
  #ALSO: to encrypt local xml files? perhaps separate method is better

  #NOTES:
  #key2 = OpenSSL::PKey::RSA.new File.read 'private_key.pem'
  #key2.public?
  #key3 = OpenSSL::PKey::RSA.new File.read 'public_key.pem'
  #key3.private? # => false
  #NEEDS base64

  keypair = OpenSSL::PKey::RSA.new(File.read("DEFINE LOCATION.pem"), password)

  #NOTES:
  #can only be decrypted with public key
  #private_encrypted = keypair.private_encrypt 'public_document'
    
  #can only be decrypted with private key
  #public_enrypted = keypair.public_encrypt 'secret_document'

  end

def decrypt_content
    
  #NOTES: opposite key to decrypt
  #secret_document = key.public_decrypt public_encrypted
  #public_document = key.private_decrypt private_encrypted
  
  end
  
  def add_signature
  #NOTES:
  #<ds:Signature Id="Signature-12345678" xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
  #<ds:SignedInfo>
  #<ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
  #<ds:SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
  #<ds:Reference URI="#id-4453123">
  #<ds:Transforms>
  #<ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
  #</ds:Transforms>
  #<ds:DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>
  #<ds:DigestValue>zYeQGz0jnyy3tI5gruq+IlGyzQo=</ds:DigestValue>
  #</ds:Reference>
  #</ds:SignedInfo>
  #<ds:SignatureValue>m5fuzJnVOQGNsu4s2kfaI+UTReUSz9pMxH...=</ds:SignatureValue>
  #<ds:KeyInfo Id="KeyId-98765432"><wsse:SecurityTokenReference wsu:Id="STRId-33454994"
  #xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">
  #<wsse:Reference URI="#CertId-9502902" ValueType="http://docs.oasis-open.org/wss/2004/01/oasis-
  #200401-wss-x509-token-profile-1.0#X509v3"/>
  #</wsse:SecurityTokenReference>
  #</ds:KeyInfo>
  #</ds:Signature>
  cert = OpenSSL::X509::Certificate.new(File.read("DEFINE LOCATION.pem"))

  cert.issuer = name
  cert.sign key, OpenSSL::Digest::SHA1.new
  #file locations undefined
  open 'TESTINGFILE.pem', 'w' do |io| io.write cert.to_pem end
  end

  def confirm_signature
  #TODO: confirm outside sender
  #could also be implemented in decrypt_content   
  end

  def compare
  #not sure if required, can extend encrypt if needed
  #comparing hash? from incoming or outgoing?
  end

end