# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'assoc_whisperer/version'

Gem::Specification.new do |spec|
  spec.name          = "assoc_whisperer"
  spec.version       = AssocWhisperer::VERSION
  spec.authors       = ["Ondřej Želazko"]
  spec.email         = ["zelazk.o@email.cz"]
  spec.summary       = %q{Rails tag assoc_whisperer for forms}
  spec.description   = %q{You can associate two models together, while user inputs e.g. name and server recieves id}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
