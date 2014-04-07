require 'minitest/autorun'
require 'simplecov'
require 'dotenv'
Dotenv.load

if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'

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

require File.expand_path('../../lib/sepafm.rb', __FILE__)
require File.expand_path('../sepa/fixtures.rb', __FILE__)
