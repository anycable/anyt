# frozen_string_literal: true

module Anyt
  # Runs system command (websocket server)
  module Command
    class << self
      attr_accessor :running

      # rubocop: disable Metrics/MethodLength
      # rubocop: disable Metrics/AbcSize
      def run
        return if @running

        AnyCable.logger.debug "Running command: #{Anyt.config.command}"

        out = AnyCable.config.debug ? STDOUT : IO::NULL

        @pid = Process.spawn(
          Anyt.config.command,
          out: out,
          err: out
        )

        Process.detach(@pid)

        AnyCable.logger.debug "Command PID: #{@pid}"

        @running = true

        sleep Anyt.config.wait_command
      end
      # rubocop: enable Metrics/MethodLength
      # rubocop: enable Metrics/AbcSize

      def stop
        return unless @running

        AnyCable.logger.debug "Terminate PID: #{@pid}"

        Process.kill("SIGKILL", @pid)

        @running = false
      end

      def running?
        @running == true
      end
    end
  end
end
