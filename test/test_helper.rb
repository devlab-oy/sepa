require 'simplecov'
SimpleCov.start
require 'minitest/autorun'
require 'turn'
require File.expand_path('../../lib/sepa.rb', __FILE__)

Turn.config.format = :outline
