require 'codeclimate-test-reporter'
require 'minitest/autorun'
require 'dotenv'
Dotenv.load

if ENV['CODECLIMATE_REPO_TOKEN']
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    CodeClimate::TestReporter::Formatter
  ]
else
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
end

SimpleCov.start do
  add_filter "/test/"
  add_filter "/vendor/"
end

require 'sepafm'
require 'sepa/fixtures'

# Test responses
NORDEA_TEST_RESPONSE_PATH = "#{ROOT_PATH}/test/sepa/banks/nordea/responses"
DANSKE_TEST_RESPONSE_PATH = "#{ROOT_PATH}/test/sepa/banks/danske/responses/"

# Test keys
DANSKE_TEST_KEYS_PATH = "#{ROOT_PATH}/test/sepa/banks/danske/keys/"
DANSKE_BANK_SIGNING_CERT = File.read "#{DANSKE_TEST_KEYS_PATH}bank_signing_cert.pem"
DANSKE_BANK_ENCRYPTION_CERT = File.read "#{DANSKE_TEST_KEYS_PATH}bank_encryption_cert.pem"
DANSKE_BANK_ROOT_CERT = File.read "#{DANSKE_TEST_KEYS_PATH}bank_root_cert.pem"
DANSKE_OWN_ENCRYPTION_CERT = File.read "#{DANSKE_TEST_KEYS_PATH}own_enc_cert.pem"

I18n.enforce_available_locales = true
