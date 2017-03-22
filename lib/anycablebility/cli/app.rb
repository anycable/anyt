# frozen_string_literal: true

require 'logger'
require 'anycablebility/rpc'
require 'anycablebility/tests'
require 'anycablebility/client_factory'

module Anycablebility
  module Cli
    # This class is the entry point of Anycablebility
    class App
      def run(
        target: 'ws://0.0.0.0:8080/cable',
        redis: 'redis://localhost:6379',
        debug: false
      )
        logger = Logger.new(STDOUT)
        logger.level = debug ? Logger::DEBUG : Logger::WARN

        rpc = Rpc.instance.configure(redis, debug, logger)

        rpc.run

        result = run_tests(target, debug, logger)

        rpc.stop

        result ? 0 : 1
      rescue => e
        rpc.stop if rpc.running? # prevent segfault from gRPC
        raise e
      end

      private

      def run_tests(target, debug, logger)
        client_factory = ClientFactory.new(target, logger)
        Anycablebility::Tests.define(client_factory)
        MiniTest.run
      end
    end
  end
end
