# frozen_string_literal: true

require "childprocess"

module Anyt
  # Runs system command (websocket server)
  module Command
    class << self
      # rubocop: disable Metrics/MethodLength
      # rubocop: disable Metrics/AbcSize
      def run
        return if running?

        return unless Anyt.config.command

        AnyCable.logger.debug "Running command: #{Anyt.config.command}"

        @process = ChildProcess.build(*Anyt.config.command.split(/\s+/))

        process.io.inherit! if AnyCable.config.debug

        process.detach = true

        process.environment["ANYCABLE_DEBUG"] = "1" if AnyCable.config.debug?
        process.environment["ANYT_REMOTE_CONTROL_PORT"] = Anyt.config.remote_control_port

        process.start

        AnyCable.logger.debug "Command PID: #{process.pid}"

        sleep Anyt.config.wait_command
        raise "Command failed to start" unless running?
      end
      # rubocop: enable Metrics/MethodLength
      # rubocop: enable Metrics/AbcSize

      def restart
        return unless running?

        AnyCable.logger.debug "Restarting command PID: #{process.pid}"

        stop
        process.wait

        run
      end

      def stop
        return unless running?

        AnyCable.logger.debug "Terminate PID: #{process.pid}"

        process.stop
      end

      def running?
        process&.alive?
      end

      private

      attr_reader :process
    end
  end
end
