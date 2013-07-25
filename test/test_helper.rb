require 'simplecov'
require 'minitest/autorun'
SimpleCov.start do
  add_filter "/test/"
  add_filter "/vendor/"
end
require File.expand_path('../../lib/sepafm.rb', __FILE__)
require File.expand_path('../sepa/fixtures.rb', __FILE__)
