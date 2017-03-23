require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new do |config|
  config.libs << ['spec', 'lib']
  config.pattern = 'spec/**/*_spec.rb'
end
desc 'Run test'

task default: :test
