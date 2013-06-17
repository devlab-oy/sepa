require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
  add_filter "/vendor/"
end
require 'minitest/autorun'
require File.expand_path('../../lib/sepa.rb', __FILE__)

class Minitest::Test
  @@fixtures = {}
  def self.fixtures list
    [list].flatten.each do |fixture|
      self.class_eval do
        # add a method name for this fixture type
        define_method(fixture) do |item|
          # load and cache the YAML
          @@fixtures[fixture] ||= YAML::load_file("sepa/fixtures/#{fixture.to_s}.yaml")
          @@fixtures[fixture][item.to_s]
        end
      end
    end
  end
end