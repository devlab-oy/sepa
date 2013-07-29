require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
  add_filter "/vendor/"
end

require 'minitest/autorun'
require File.expand_path('../../lib/sepa.rb', __FILE__)