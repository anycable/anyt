# frozen_string_literal: true

require "anyt/dummy/application"
require "anycable-rails"
require "redis"

module Anyt # :nodoc:
  # Runs AnyCable RPC server in the background
  module RPC
    using AsyncHelpers

    class << self
      attr_accessor :running
      attr_reader :server

      # rubocop: disable Metrics/AbcSize,Metrics/MethodLength
      def start
        AnyCable.logger.debug "Starting RPC server ..."

        AnyCable.server_callbacks.each(&:call)

        @server = AnyCable::GRPC::Server.new(
          host: AnyCable.config.rpc_host,
          **AnyCable.config.to_grpc_params
        )

        if defined?(::AnyCable::Middlewares::EnvSid)
          AnyCable.middleware.use(::AnyCable::Middlewares::EnvSid)
        end

        AnyCable.middleware.freeze

        server.start

        AnyCable.logger.debug "RPC server started"
      end
      # rubocop: enable Metrics/AbcSize,Metrics/MethodLength

      def stop
        server&.stop
      end
    end

    AnyCable.connection_factory = ActionCable.server.config.connection_class.call
    AnyCable.config.log_level = :fatal unless AnyCable.config.debug
  end
end
