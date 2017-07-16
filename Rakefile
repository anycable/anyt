# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new do |config|
  config.libs << %w[spec lib]
  config.pattern = "spec/**/*_spec.rb"
end
desc "Run test"

task default: :test
