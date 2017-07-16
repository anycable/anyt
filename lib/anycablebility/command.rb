# frozen_string_literal: true

module Anycablebility
  # Runs system command (websocket server)
  module Command
    class << self
      attr_accessor :running

      # rubocop: disable Metrics/MethodLength
      # rubocop: disable Metrics/AbcSize
      def run
        return if @running

        Anycable.logger.debug "Running command: #{Anycablebility.config.command}"

        out = Anycable.config.debug ? STDOUT : IO::NULL

        @pid = Process.spawn(
          Anycablebility.config.command,
          out: out,
          err: out
        )

        Process.detach(@pid)

        Anycable.logger.debug "Command PID: #{@pid}"

        @running = true

        sleep Anycablebility.config.wait_command
      end
      # rubocop: enable Metrics/MethodLength
      # rubocop: enable Metrics/AbcSize

      def stop
        return unless @running

        Anycable.logger.debug "Terminate PID: #{@pid}"

        Process.kill("SIGKILL", @pid)

        @running = false
      end

      def running?
        @running == true
      end
    end
  end
end
