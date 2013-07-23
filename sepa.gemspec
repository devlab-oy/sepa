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
  spec.authors       = ['Joni Kanerva', 'Mika Myllynen', 'Tommi Järvinen']
  spec.email         = ['joni@devlab.fi']
  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '~> 2.0.0'

  spec.add_dependency 'savon',    '~> 2.2.0'
  spec.add_dependency 'nokogiri', '~> 1.6.0'

  spec.add_development_dependency 'bundler',   '~> 1.3.5'
  spec.add_development_dependency 'rake',      '~> 10.1.0'
  spec.add_development_dependency 'simplecov', '~> 0.7.1'
  spec.add_development_dependency 'minitest',  '~> 5.0.3'
  spec.add_development_dependency 'json',      '~> 1.8.0'
end
