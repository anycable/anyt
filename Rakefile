require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :ac do
  require 'anycablebility/server/action_cable'
  Anycablebility::Server::ActionCable.run
end

task :rpc do
  require 'anycablebility/server/rpc'
  Anycablebility::Server::RPC.run
end
