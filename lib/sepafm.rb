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
require 'sepa/custom_exceptions'
require 'sepa/response'
require 'sepa/banks/nordea/nordea_response'
require 'sepa/banks/danske/danske_response'
require 'sepa/soap_builder'
require 'sepa/banks/danske/soap_danske'
require 'sepa/banks/nordea/soap_nordea'
require 'sepa/version'

ROOT_PATH = File.absolute_path('.')
WSDL_PATH = "#{ROOT_PATH}/lib/sepa/wsdl"
SCHEMA_PATH = "#{ROOT_PATH}/lib/sepa/xml_schemas"
SCHEMA_FILE = "#{ROOT_PATH}/lib/sepa/xml_schemas/wsdl.xml"
AR_TEMPLATE_PATH = "#{ROOT_PATH}/lib/sepa/xml_templates/application_request"
SOAP_TEMPLATE_PATH = "#{ROOT_PATH}/lib/sepa/xml_templates/soap"
