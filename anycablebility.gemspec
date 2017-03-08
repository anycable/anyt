# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'anycablebility/version'

Gem::Specification.new do |spec|
  spec.name          = "anycablebility"
  spec.version       = Anycablebility::VERSION
  spec.authors       = ["palkan"]
  spec.email         = ["dementiev.vm@gmail.com"]

  spec.summary       = %q{Anycable conformance testing tool}
  spec.description   = %q{Anycable conformance testing tool}
  spec.homepage      = "http://github.com/anycable/anycablebility"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.executables << 'anycablebility'

  spec.add_dependency "rack", "~> 2"
  spec.add_dependency "minitest", "~> 5.10.1"
  spec.add_dependency "rails", "~> 5.0.1"
  spec.add_dependency "anycable-rails", "0.4.4"
  spec.add_dependency "websocket-eventmachine-client", "~> 1.2.0"
  spec.add_dependency "docopt", "~> 0.5.0"

  spec.add_development_dependency "bundler", "~> 1"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "simplecov", ">= 0.3.8"
  spec.add_development_dependency "rubocop", "~> 0.47.1"
  spec.add_development_dependency "pry", "~> 0.10.4"
end
