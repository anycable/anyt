# frozen_string_literal: true

require "logger"
require "optparse"

require "anyt/version"
require "anyt/remote_control"
require "anyt/rpc"
require "anyt/command"
require "anyt/tests"

module Anyt
  module Cli # :nodoc:
    class << self
      # CLI entrypoint
      def run
        parse_options!

        ActionCable.server.config.logger = Rails.logger = AnyCable.logger

        result = 1

        $stdout.puts "Starting AnyT v#{Anyt::VERSION} (pid: #{Process.pid})\n"

        begin
          # Load all test scenarios
          Tests.load_tests

          # Start RPC server (unless specified otherwise, e.g. when
          # we want to test Action Cable itself)
          unless @skip_rpc
            require "anycable-rails"
            RPC.start

            if @only_rpc
              RPC.server.wait_till_terminated
              return
            end
          end

          # Start webosocket server under test
          Command.run

          # Run tests
          result = Tests.run ? 0 : 1
        ensure
          RPC.stop unless @skip_rpc
          Command.stop
        end

        result
      end

      private

      def parse_options!
        parser =
          OptionParser.new do |cli|
            cli.banner = <<~BANNER
              Anyt – AnyCable websocket server conformance tool.

              Usage: anyt [options]

              Options:
            BANNER

            cli.on("-cCOMMAND", "--command=COMMAND", "Command to run WS server.") do |command|
              Anyt.config.command = command
            end

            cli.on("--target-url=TARGET", "URL of target WebSocket server to test.") do |target|
              Anyt.config.target_url = target
            end

            cli.on("--redis-url=REDIS_URL", "Redis server URL.") do |redis|
              AnyCable.config.redis_url = redis
            end

            cli.on("--skip-rpc", TrueClass, "Do not run RPC server") do |flag|
              @skip_rpc = flag
            end

            cli.on("--only-rpc", TrueClass, "Run only RPC server") do |flag|
              @only_rpc = flag
            end

            cli.on("--self-check", "Run tests again Action Cable itself") do
              @skip_rpc = true
              dummy_path = ::File.expand_path(
                "config.ru",
                ::File.join(::File.dirname(__FILE__), "dummy")
              )
              Anyt.config.command = "bundle exec puma #{dummy_path}"
              Anyt.config.use_action_cable = true
            end

            cli.on("--only test1,test2,test3", Array, "Run only specified tests") do |only_tests|
              Anyt.config.only_tests = only_tests
            end

            cli.on("--wait-command=TIMEOUT", Integer,
              "Number of seconds to wait for WS server initialization") do |timeout|
              Anyt.config.wait_command = timeout
            end

            cli.on("-rPATH", "--require=PATH",
              "Path to additional tests (e.g. features/*.rb") do |path|
              Anyt.config.tests_relative_path = path
              ENV["ANYT_TESTS_RELATIVE_PATH"] = path
            end

            cli.on("--debug", "Enable debug mode.") do
              AnyCable.config.debug = true
            end

            cli.on("-h", "--help", "Show this message.") do
              puts cli
              exit
            end

            cli.on("--version", "Print version.") do
              puts Anyt::VERSION
              exit
            end
          end

        parser.parse!
      rescue OptionParser::InvalidOption => e
        unknown_option = e.args.first
        puts "This option looks unfamiliar: #{unknown_option}. A typo?"
        puts "Use `anyt --help` to list all available options."
        exit 1
      end
    end
  end
end
