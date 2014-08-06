require 'active_model'
require 'base64'
require 'nokogiri'
require 'openssl'
require 'savon'
require 'securerandom'
require 'time'
require 'sepa/utilities'
require 'sepa/error_messages'
require 'sepa/attribute_checks'
require 'sepa/application_request'
require 'sepa/application_response'
require 'sepa/client'
require 'sepa/response'
require 'sepa/banks/nordea/nordea_response'
require 'sepa/banks/danske/danske_response'
require 'sepa/soap_builder'
require 'sepa/banks/danske/soap_danske'
require 'sepa/banks/nordea/soap_nordea'
require 'sepa/version'

ROOT_PATH = File.expand_path('../../', __FILE__)
WSDL_PATH = "#{ROOT_PATH}/lib/sepa/wsdl"
SCHEMA_PATH = "#{ROOT_PATH}/lib/sepa/xml_schemas"
SCHEMA_FILE = "#{ROOT_PATH}/lib/sepa/xml_schemas/wsdl.xml"
AR_TEMPLATE_PATH = "#{ROOT_PATH}/lib/sepa/xml_templates/application_request"
SOAP_TEMPLATE_PATH = "#{ROOT_PATH}/lib/sepa/xml_templates/soap"

# Certificates
CERTIFICATE_PATH = "#{ROOT_PATH}/lib/sepa/certificates/"
nordea_root_certificate_string = File.read("#{CERTIFICATE_PATH}nordea_root_certificate.cer")
NORDEA_ROOT_CERTIFICATE = OpenSSL::X509::Certificate.new nordea_root_certificate_string
danske_root_certificate_string = File.read("#{CERTIFICATE_PATH}danske_root_certificate.cer")
DANSKE_ROOT_CERTIFICATE = OpenSSL::X509::Certificate.new danske_root_certificate_string

# Common XML namespaces
DSIG = 'http://www.w3.org/2000/09/xmldsig#'
OASIS_UTILITY = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'
OASIS_SECEXT = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'
XML_DATA = 'http://bxd.fi/xmldata/'
BXD = 'http://model.bxd.fi'
XMLENC = 'http://www.w3.org/2001/04/xmlenc#'
ENVELOPE = 'http://schemas.xmlsoap.org/soap/envelope/'

# Nordea XML namespaces
NORDEA_PKI = 'http://bxd.fi/CertificateService'
NORDEA_XML_DATA = 'http://filetransfer.nordea.com/xmldata/'

# Danske XML namespaces
DANSKE_PKI  = 'http://danskebank.dk/PKI/PKIFactoryService/elements'
DANSKE_PKIF = 'http://danskebank.dk/PKI/PKIFactoryService'
