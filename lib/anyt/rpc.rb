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
        Anycable.logger.debug "Starting RPC server ..."

        @thread = Thread.new { Anycable::Server.start }
        @thread.abort_on_exception = true

        wait(2) { Anycable::Server.running? }

        Anycable.logger.debug "RPC server started"
      end

      def stop
        return unless Anycable::Server.running?

        Anycable::Server.grpc_server.stop
      end
    end

    Anycable.connection_factory = ActionCable.server.config.connection_class.call
    Anycable.logger = Logger.new(IO::NULL) unless Anycable.config.debug
  end
end
