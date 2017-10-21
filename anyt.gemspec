# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "anyt/version"

Gem::Specification.new do |spec|
  spec.name          = "anyt"
  spec.version       = Anyt::VERSION
  spec.authors       = ["palkan"]
  spec.email         = ["dementiev.vm@gmail.com"]

  spec.summary       = "Anycable conformance testing tool"
  spec.description   = "Anycable conformance testing tool"
  spec.homepage      = "http://github.com/anycable/anyt"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.executables << "anyt"

  spec.add_dependency "rack", "~> 2"
  spec.add_dependency "minitest", "~> 5.10.1"
  spec.add_dependency "minitest-reporters", "~> 1.1.0"
  spec.add_dependency "rails", "~> 5.0"
  spec.add_dependency "anycable-rails", "~> 0.5.0"
  spec.add_dependency "redis", "~> 3.0"
  spec.add_dependency "websocket", "~> 1.2.4"
  spec.add_dependency "websocket-client-simple", "~> 0.3.0"
  spec.add_dependency "concurrent-ruby", "~> 1.0.0"

  spec.add_development_dependency "bundler", "~> 1"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "simplecov", ">= 0.3.8"
  spec.add_development_dependency "rubocop", "~> 0.50"
  spec.add_development_dependency "pry", "~> 0.10.4"
  spec.add_development_dependency "puma", "~> 3.6"
  spec.add_development_dependency "pry-byebug"
end
