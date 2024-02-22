# frozen_string_literal: true

source "https://rubygems.org"

gem "pry-byebug", platform: :mri

eval_gemfile "gemfiles/rubocop.gemfile"

# Specify your gem's dependencies in anyt.gemspec
gemspec name: "anyt"

if File.directory?(File.join(__dir__, "../anycable"))
  $stdout.puts "\n=== Using local AnyCable gems ===\n\n"
  path ".." do
    gem "anycable"
    gem "anycable-rails"
  end
else
  gem "anycable", github: "anycable/anycable"
  gem "anycable-rails", github: "anycable/anycable-rails"
end

if File.directory?(File.join(__dir__, "../../rails"))
  $stdout.puts "\n=== Using local Rails ===\n\n"
  path "../../rails" do
    gem "rails"
  end
else
  gem "rails"
end
