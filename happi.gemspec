# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'happi/version'

Gem::Specification.new do |spec|
  spec.name          = "happi"
  spec.version       = Happi::VERSION
  spec.authors       = ["John D'Agostino"]
  spec.email         = ["john.dagostino@gmail.com"]
  spec.description   = %q{Simple faraday client preconfigured}
  spec.summary       = %q{Simple faraday client wrapper preconfigured for specific usecase}
  spec.homepage      = "http://github.com/jobready/happi"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday', '~> 1.0'
  spec.add_dependency 'faraday_middleware', '~> 1.0'
  spec.add_dependency 'activemodel', '>= 3.2'
  spec.add_dependency 'oauth2', '~> 1.0'
  spec.add_dependency 'mime-types', '>= 1.1.6'
  spec.add_dependency 'multi_json', '~> 1.3'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'cane'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rack-test'
end
