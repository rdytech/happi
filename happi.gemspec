# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'happi/version'

Gem::Specification.new do |spec|
  spec.name          = "happi"
  spec.version       = Happi::VERSION
  spec.authors       = ["John D'Agostino"]
  spec.email         = ["john.dagostino@gmail.com"]
  spec.description   = %q{TODO: Write a gem description}
  spec.summary       = %q{TODO: Write a gem summary}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'activemodel'
  spec.add_dependency 'oauth2'
  spec.add_dependency 'mime-types'
  spec.add_dependency 'multi_json'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'cane'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
