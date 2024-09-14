# frozen_string_literal: true

require "childprocess"

module Anyt
  # Runs system command (websocket server)
  class Command
    class << self
      attr_reader :instance

      def default
        @instance ||= new
      end

      def restart
        instance&.restart
      end
    end

    attr_reader :cmd

    def initialize(cmd = Anyt.config.command)
      @cmd = cmd
    end

    def run
      return if running?

      return unless cmd

      AnyCable.logger.debug "Running command: #{cmd}"

      @process = ChildProcess.build(*cmd.split(/\s+/))

      process.io.inherit! if AnyCable.config.debug

      process.detach = true

      process.environment["ANYCABLE_DEBUG"] = "1" if AnyCable.config.debug?
      process.environment["ANYT_REMOTE_CONTROL_PORT"] = Anyt.config.remote_control_port
      process.environment["ACTION_CABLE_ADAPTER"] = "any_cable" unless Anyt.config.use_action_cable

      process.start

      AnyCable.logger.debug "Command PID: #{process.pid}"

      sleep Anyt.config.wait_command
      raise "Command failed to start" unless running?
    end

    alias_method :start, :run

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
