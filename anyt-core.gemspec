# frozen_string_literal: true

require_relative "lib/anyt/version"

Gem::Specification.new do |spec|
  spec.name = "anyt-core"
  spec.version = Anyt::VERSION
  spec.authors = ["palkan"]
  spec.email = ["dementiev.vm@gmail.com"]

  spec.summary = "Action Cable / AnyCable conformance testing tool"
  spec.description = "Action Cable / AnyCable conformance testing tool"
  spec.homepage = "http://github.com/anycable/anyt"
  spec.license = "MIT"

  spec.files = Dir.glob("lib/**/*") + Dir.glob("bin/*") + %w[README.md MIT-LICENSE]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.6.0"

  spec.add_dependency "rack", ">= 2.0"
  spec.add_dependency "rails", ">= 6.0"
  spec.add_dependency "anyway_config", ">= 2.2.0"
  spec.add_dependency "websocket", "~> 1.2.4"
  spec.add_dependency "websocket-client-simple", "~> 0.8"
  spec.add_dependency "concurrent-ruby", "~> 1.0"
end
