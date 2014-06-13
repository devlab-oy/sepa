lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sepa/version'

Gem::Specification.new do |spec|
  spec.name          = 'sepafm'
  spec.version       = Sepa::VERSION
  spec.summary       = 'SEPA Financial Messages'
  spec.description   = 'SEPA Financial Messages using Web Services'
  spec.homepage      = 'https://github.com/devlab-oy/sepa'
  spec.license       = 'MIT'
  spec.authors       = ['Joni Kanerva', 'Mika Myllynen', 'Tommi Jarvinen']
  spec.email         = ['joni@devlab.fi']
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'savon',       '~> 2.4.0'
  spec.add_dependency 'nokogiri',    '~> 1.6.1'
  spec.add_dependency 'activemodel', '~> 4.1.1'
  spec.add_dependency 'minitest',    '~> 5.3'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'codeclimate-test-reporter'
  spec.add_development_dependency 'dotenv'
end
