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
  spec.homepage      = "https://github.com/rdytech/happi"
  spec.license       = "MIT"
  spec.required_ruby_version = '>= 3.2.0'

  # Ship only what a consumer needs at runtime. Specs (and their 2MB fixture),
  # research notes and CI/editor config stay in the repo but out of the gem.
  excluded_prefixes = %w[spec/ context/ .github/ .devcontainer/]
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.start_with?(*excluded_prefixes) || f.end_with?('.gem')
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'faraday', '>= 1.10.0'
  spec.add_dependency 'faraday-multipart', '~> 1.1'
  spec.add_dependency 'activesupport', '>= 6.0'
  spec.add_dependency 'mime-types', '>= 2.4.0'

  spec.add_development_dependency 'bundler', '>= 2.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'cane'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rack-test'
end
