# frozen_string_literal: true

require 'singleton'

module Anycablebility
  # RPC server
  class Rpc
    include Singleton

    def initialize
      require 'anycablebility/dummy/application'
      require 'anycable/rails'
      require 'anycable-rails'

      @state = :initial
    end

    def configure(redis_url, debug, logger)
      raise 'Already configured' if @state != :initial

      @redis_url = redis_url
      @debug = debug
      @logger = logger

      @state = :configured

      self
    end

    def run
      raise 'Not configured' if @state == :initial
      raise 'Already running' if @state == :running

      load_dummy

      configure_anycable

      @thread = Thread.new { Anycable::Server.start }
      @thread.abort_on_exception = true

      @state = :running
    end

    def stop
      raise 'Not running' if @state != :running

      Anycable::Server.grpc_server.stop

      @state = :stopped
    end

    def running?
      @state == :running
    end

    private

    def configure_anycable
      Anycable.logger = @logger
      Anycable.configure do |config|
        config.debug = @debug
        config.redis_url = @redis_url
        config.connection_factory = ActionCable.server.config.connection_class.call
      end
    end

    def load_dummy
      pattern = File.expand_path('dummy/**/*.rb', __dir__)

      Dir.glob(pattern).each { |file| require file }
    end
  end
end
