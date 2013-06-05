# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "wasabi"
  s.version = "3.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Harrington"]
  s.date = "2012-12-17"
  s.description = "A simple WSDL parser"
  s.email = ["me@rubiii.com"]
  s.homepage = "https://github.com/rubiii/wasabi"
  s.require_paths = ["lib"]
  s.rubyforge_project = "wasabi"
  s.rubygems_version = "2.0.3"
  s.summary = "A simple WSDL parser"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<httpi>, ["~> 2.0"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.4.0"])
      s.add_development_dependency(%q<rake>, ["~> 0.9"])
      s.add_development_dependency(%q<rspec>, ["~> 2.10"])
    else
      s.add_dependency(%q<httpi>, ["~> 2.0"])
      s.add_dependency(%q<nokogiri>, [">= 1.4.0"])
      s.add_dependency(%q<rake>, ["~> 0.9"])
      s.add_dependency(%q<rspec>, ["~> 2.10"])
    end
  else
    s.add_dependency(%q<httpi>, ["~> 2.0"])
    s.add_dependency(%q<nokogiri>, [">= 1.4.0"])
    s.add_dependency(%q<rake>, ["~> 0.9"])
    s.add_dependency(%q<rspec>, ["~> 2.10"])
  end
end
