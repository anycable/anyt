# frozen_string_literal: true

require 'anycablebility/rpc'
require 'anycablebility/tests'
require 'anycablebility/client_factory'

module Anycablebility
  module Cli
    # This class is the entry point of Anycablebility
    class App
      def initialize(args)
        @args = args
      end

      def run
        rpc = Rpc.instance

        rpc.configure(@args['--redis'], @args['--debug'])

        rpc.run

        run_tests

        rpc.stop
      rescue => e
        rpc.stop if rpc.running?
        raise e
      end

      private

      def run_tests
        client_factory = ClientFactory.new(@args['--target'], @args['--debug'])
        Anycablebility::Tests.define(client_factory)
        MiniTest.run
      end
    end
  end
end
