# frozen_string_literal: true
module Anycablebility
  # General server wrapper: load channels code, setup logger
  class Server
    require "action_cable"

    class << self
      def run(**options)
        new(**options).run
      end
    end

    attr_accessor :logger

    def initialize(**options)
      init_channels
      init_pubsub
      init_logger
    end

    def run
      raise NotImplementedError
    end

    protected

    def init_channels
      # TODO:
    end

    def init_pubsub
      # TODO:
    end

    def init_logger
      @logger = Logger.new(STDOUT)
    end
  end
end
