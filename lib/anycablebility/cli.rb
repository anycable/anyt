# frozen_string_literal: true

require "logger"
require "optparse"

require "anycablebility/rpc"
require "anycablebility/command"
require "anycablebility/tests"

# rubocop: disable Metrics/AbcSize
# rubocop: disable Metrics/MethodLength
# rubocop: disable Metrics/BlockLength
module Anycablebility
  module Cli # :nodoc:
    class << self
      # CLI entrypoint
      def run
        parse_options!

        ActionCable.server.config.logger = Rails.logger = Anycable.logger

        result = 1

        begin
          # Load all test scenarios
          Tests.load_tests

          # Start RPC server (unless specified otherwise, e.g. when
          # we want to test Action Cable itself)
          unless @skip_rpc
            require "anycable-rails"
            RPC.start
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
              Anycablebility – AnyCable websocket server conformance tool.

              Usage: anycablebility [options]

              Options:
            BANNER

            cli.on("-cCOMMAND", "--command=COMMAND", "Command to run WS server.") do |command|
              Anycablebility.config.command = command
            end

            cli.on("--target-url=TARGET", "URL of target WebSocket server to test.") do |target|
              Anycablebility.config.target_url = target
            end

            cli.on("--redis-url=REDIS_URL", "Redis server URL.") do |redis|
              Anycable.config.redis_url = redis
            end

            cli.on("--skip-rpc", TrueClass, "Do not run RPC server") do |flag|
              @skip_rpc = flag
            end

            cli.on("--self-check", "Run tests again Action Cable itself") do
              @skip_rpc = true
              dummy_path = ::File.expand_path(
                "config.ru",
                ::File.join(::File.dirname(__FILE__), "dummy")
              )
              Anycablebility.config.command = "bundle exec puma #{dummy_path}"
            end

            cli.on("--only test1,test2,test3", Array, "Run only specified tests") do |only_tests|
              Anycablebility.config.only_tests = only_tests
            end

            cli.on("--wait-command=TIMEOUT", Integer,
                   "Number of seconds to wait for WS server initialization") do |timeout|
              Anycablebility.config.wait_command = timeout
            end

            cli.on("--debug", "Enable debug mode.") do
              Anycable.config.debug = true
            end

            cli.on("-h", "--help", "Show this message.") do
              puts cli
              exit
            end

            cli.on("--version", "Print version.") do
              puts Anycablebility::VERSION
              exit
            end
          end

        parser.parse!
      rescue OptionParser::InvalidOption => e
        unknown_option = e.args.first
        puts "This option looks unfamiliar: #{unknown_option}. A typo?"
        puts "Use `anycablebility --help` to list all available options."
        exit 1
      end
    end
  end
end
