# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'assoc_whisperer/version'

Gem::Specification.new do |spec|
  spec.name          = "assoc_whisperer"
  spec.version       = AssocWhisperer::VERSION
  spec.authors       = ["Ondřej Želazko"]
  spec.email         = ["zelazk.o@email.cz"]
  spec.summary       = %q{Rails whisperer tag for forms}
  spec.description   = %q{Input associated models directly by id}
  spec.homepage      = "https://github.com/doooby/assoc_whisperer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  # spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  # spec.add_development_dependency 'cucumber'
  # spec.add_development_dependency 'capybara-webkit'
end
