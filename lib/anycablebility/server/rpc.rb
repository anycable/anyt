# frozen_string_literal: true
require "anycablebility/server/base"

module Anycablebility
  module Server
    # AnyCable server wrapper
    class RPC < Base
      require "anycable"
      require 'anycable/server'

      def run
        Anycable::Server.start
      end

      protected

      def init_logger
        super
        Anycable.logger = logger
      end
    end
  end
end
