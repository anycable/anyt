# frozen_string_literal: true

require_relative "lib/anyt/version"

Gem::Specification.new do |spec|
  spec.name = "anyt"
  spec.version = Anyt::VERSION
  spec.authors = ["palkan"]
  spec.email = ["dementiev.vm@gmail.com"]

  spec.summary = "Action Cable / AnyCable conformance testing tool"
  spec.description = "Action Cable / AnyCable conformance testing tool"
  spec.homepage = "http://github.com/anycable/anyt"
  spec.license = "MIT"

  spec.files = %w[README.md MIT-LICENSE]
  spec.require_paths = ["lib"]

  spec.executables << "anyt"

  spec.add_dependency "anyt-core", Anyt::VERSION

  spec.add_dependency "minitest", "~> 5.10"
  spec.add_dependency "minitest-reporters", "~> 1.1.0"
  spec.add_dependency "anycable-rails", "> 1.0.99", "< 2.0"
  spec.add_dependency "redis", "~> 4.0"
  spec.add_dependency "childprocess", "~> 3.0"

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "puma", "~> 3.6"
end
