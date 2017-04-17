# frozen_string_literal: true

module Anycablebility # :nodoc:
  require "anycablebility/dummy/application"
  require "anycable-rails"

  Anycable.configure do |config|
    config.connection_factory = ActionCable.server.config.connection_class.call
  end

  ActionCable.server.config.logger = Rails.logger = Anycable.logger

  # Runs AnyCable RPC server in the background
  module RPC
    using AsyncHelpers

    class << self
      attr_accessor :running

      def start
        Anycable.logger.debug "Starting RPC server ..."

        @thread = Thread.new { Anycable::Server.start }
        @thread.abort_on_exception = true

        wait(2) { running? }

        Anycable.logger.debug "RPC server started"
      end

      def stop
        return unless running?

        Anycable::Server.grpc_server.stop
      end

      def running?
        Anycable::Server.grpc_server&.running_state == :running
      end
    end
  end
end
