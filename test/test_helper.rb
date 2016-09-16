require 'codeclimate-test-reporter'
require 'minitest/autorun'
require 'dotenv'
Dotenv.load

if ENV['CODECLIMATE_REPO_TOKEN']
  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    CodeClimate::TestReporter::Formatter,
  ]
else
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
end

SimpleCov.start do
  add_filter "/test/"
  add_filter "/vendor/"
end

require 'custom_assertions'
require 'sepafm'
require 'sepa/fixtures'

include Sepa::Utilities

ActiveSupport::TestCase.test_order = :random

# Test responses
NORDEA_TEST_RESPONSE_PATH = "#{ROOT_PATH}/test/sepa/banks/nordea/responses".freeze
DANSKE_TEST_RESPONSE_PATH = "#{ROOT_PATH}/test/sepa/banks/danske/responses/".freeze

# Danske Test keys
DANSKE_TEST_KEYS_PATH = "#{ROOT_PATH}/test/sepa/banks/danske/keys/".freeze
DANSKE_BANK_SIGNING_CERT = File.read "#{DANSKE_TEST_KEYS_PATH}bank_signing_cert.pem"
DANSKE_BANK_ENCRYPTION_CERT = File.read "#{DANSKE_TEST_KEYS_PATH}bank_encryption_cert.pem"
DANSKE_BANK_ROOT_CERT = File.read "#{DANSKE_TEST_KEYS_PATH}bank_root_cert.pem"
DANSKE_OWN_ENCRYPTION_CERT = File.read "#{DANSKE_TEST_KEYS_PATH}own_enc_cert.pem"

# Nordea test keys
NORDEA_TEST_KEYS_PATH = "#{ROOT_PATH}/test/sepa/banks/nordea/keys/".freeze
NORDEA_SIGNING_CERTIFICATE = File.read "#{NORDEA_TEST_KEYS_PATH}nordea.crt"

I18n.enforce_available_locales = true

# Create an observer to fake sending requests to bank
observer = Class.new do
  def notify(operation_name, builder, globals, locals)
    @operation_name = operation_name
    @builder = builder
    @globals = globals
    @locals  = locals
    HTTPI::Response.new(200, { "Reponse is actually" => "the request, w0000t" }, locals[:xml])
  end
end.new

Savon.observers << observer
