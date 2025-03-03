# frozen_string_literal: true

require "logger"
require "optparse"

require "anyt/version"
require "anyt/remote_control"
require "anyt/rpc"
require "anyt/command"
require "anyt/tests"

$stdout.sync = true

module Anyt
  module Cli # :nodoc:
    DUMMY_ROOT = ::File.expand_path(
      "config.ru",
      ::File.join(::File.dirname(__FILE__), "dummy")
    )

    RAILS_COMMAND = "bundle exec puma #{DUMMY_ROOT} -t #{ENV.fetch("RAILS_MAX_THREADS", 5)} -p #{ENV.fetch("PUMA_PORT", 9292)}"

    class << self
      # CLI entrypoint
      def run(args = ARGV)
        parse_options!(args)

        if Anyt.config.list_tests
          Tests.load_tests
          Tests.list
          return 0
        end

        ActionCable.server.config.logger = Rails.logger = AnyCable.logger

        result = 1

        $stdout.puts "Starting AnyT v#{Anyt::VERSION} (pid: #{Process.pid})\n"

        begin
          # "Enable" AnyCable as early as possible to activate all the features in tests
          unless Anyt.config.use_action_cable
            ActionCable.server.config.cable = {"adapter" => "any_cable"}
            require "anycable-rails"
          end

          # Load all test scenarios
          Tests.load_tests unless @skip_tests

          Rails.application.initialize!

          # Start RPC server (unless specified otherwise, e.g. when
          # we want to test Action Cable itself)
          unless @skip_rpc
            http_rpc = AnyCable.config.http_rpc_mount_path.present?

            @rpc_command =
              if http_rpc
                Command.new(RAILS_COMMAND)
              else
                RPC.new
              end

            @rpc_command.start

            if @only_rpc
              if http_rpc
                wait_till_terminated
              else
                @rpc_command.server.wait_till_terminated
              end
              return
            end
          end

          # Start webosocket server under test
          @command = Command.default
          @command.run

          unless @skip_tests
            # Run tests
            result = Tests.run ? 0 : 1
          end

          wait_till_terminated if @only_rails
        rescue Interrupt => e
          $stdout.puts "#{e.message}. Good-bye!"
        ensure
          @rpc_command&.stop unless @skip_rpc
          @command&.stop
        end

        result
      end

      private

      def parse_options!(args)
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

            cli.on("--only-rails", TrueClass, "Run only Rails server") do
              @skip_rpc = true
              @only_rails = true
              @skip_tests = true

              configure_rails_command!
            end

            cli.on("-l", "--list", TrueClass, "List test scenarios") do
              Anyt.config.list_tests = true
              @skip_rpc = true
            end

            cli.on("--self-check", "Run tests again Action Cable itself") do
              @skip_rpc = true

              configure_rails_command!
            end

            cli.on("--rails-command=COMMAND", "A custom command to run Rails server") do |cmd|
              configure_rails_command!(cmd)
              Anyt.config.custom_action_cable = true
            end

            cli.on("--only test1,test2,test3", Array, "Run only specified tests") do |only_tests|
              Anyt.config.only_tests = only_tests
            end

            cli.on("--except test1,test2,test3", Array, "Exclude specified tests") do |except_tests|
              Anyt.config.except_tests = except_tests
            end

            cli.on("-e filter", "Run only tests matching the descripton") do |filter_tests|
              Anyt.config.filter_tests = filter_tests
            end

            cli.on("--wait-command=TIMEOUT", Integer,
              "Number of seconds to wait for WS server initialization") do |timeout|
              Anyt.config.wait_command = timeout
            end

            cli.on("--timeout-multiplier=VALUE", Float,
              "Default exceptation timeouts multiplier") do |val|
              Anyt.config.timeout_multiplier = val
            end

            cli.on("-rPATH", "--require=PATH",
              "Paths to additional tests (e.g. features/*.rb") do |paths|
              Anyt.config.tests_relative_path = paths
              ENV["ANYT_TESTS_RELATIVE_PATH"] = paths
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

        parser.parse!(args)
      rescue OptionParser::InvalidOption => e
        unknown_option = e.args.first
        puts "This option looks unfamiliar: #{unknown_option}. A typo?"
        puts "Use `anyt --help` to list all available options."
        exit 1
      end

      def configure_rails_command!(cmd = RAILS_COMMAND)
        Anyt.config.command = cmd % {config: DUMMY_ROOT}
        Anyt.config.use_action_cable = true
      end

      def wait_till_terminated
        self_read = setup_signals

        while readable_io = IO.select([self_read]) # rubocop:disable Lint/AssignmentInCondition, Lint/IncompatibleIoSelectWithFiberScheduler
          signal = readable_io.first[0].gets.strip
          raise Interrupt, "SIG#{signal} received"
        end
      end

      def setup_signals
        self_read, self_write = IO.pipe

        %w[INT TERM].each do |signal|
          trap signal do
            self_write.puts signal
          end
        end

        self_read
      end
    end
  end
end
