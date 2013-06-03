lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sepa/version'

Gem::Specification.new do |spec|
  spec.name          = "sepa"
  spec.version       = Sepa::VERSION
  spec.summary       = "SEPA Financial Messages"
  spec.description   = "SEPA Financial Messages using Web Services"
  spec.homepage      = "https://github.com/devlab-oy/sepa"
  spec.license       = "MIT"
  spec.authors       = ["Joni Kanerva"]
  spec.email         = ["joni@devlab.fi"]

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 1.9.3'

  spec.add_dependency "savon",       "~> 2.1.0"
  spec.add_dependency "nokogiri",    "~> 1.5.9"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'json'
end
