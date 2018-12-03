# frozen_string_literal: true

module Anyt # :nodoc:
  require "anyt/dummy/application"
  require "anycable"

  # Runs AnyCable RPC server in the background
  module RPC
    using AsyncHelpers

    class << self
      attr_accessor :running

      def start
        AnyCable.logger.debug "Starting RPC server ..."

        @thread = Thread.new { AnyCable::Server.start }
        @thread.abort_on_exception = true

        wait(2) { AnyCable::Server.running? }

        AnyCable.logger.debug "RPC server started"
      end

      def stop
        return unless AnyCable::Server.running?

        AnyCable::Server.grpc_server.stop
      end
    end

    AnyCable.connection_factory = ActionCable.server.config.connection_class.call
    AnyCable.logger = Logger.new(IO::NULL) unless AnyCable.config.debug
  end
end
