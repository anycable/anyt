# frozen_string_literal: true

module Anycablebility
  # Runs system command (websocket server)
  module Command
    class << self
      attr_accessor :running

      # rubocop: disable Metrics/MethodLength
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

        sleep Anycablebility.config.wait_command

        @running = true
      end
      # rubocop: enable Metrics/MethodLength

      def stop
        return unless @running

        Process.kill("TERM", @pid)

        @running = false
      end

      def running?
        @running == true
      end
    end
  end
end
