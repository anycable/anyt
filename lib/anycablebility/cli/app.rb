# frozen_string_literal: true

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
        rpc = Rpc.instance

        rpc.configure(redis, debug)

        rpc.run

        run_tests(target, debug)

        rpc.stop
      rescue => e
        rpc.stop if rpc.running? # prevent segfault from gRPC
        raise e
      end

      private

      def run_tests(target, debug)
        logger = Logger.new(debug ? STDOUT : IO::NULL)
        client_factory = ClientFactory.new(target, logger)
        Anycablebility::Tests.define(client_factory)
        MiniTest.run
      end
    end
  end
end
