# frozen_string_literal: true

require "drb/drb"

module Anyt
  # Invoke commands within the running Ruby (Action Cable) server
  module RemoteControl
    class Server
      class << self
        alias start new
      end

      def initialize(port)
        DRb.start_service(
          "druby://localhost:#{port}",
          Client.new
        )
      end
    end

    class Client
      def self.connect(port)
        DRb.start_service

        DRbObject.new_with_uri("druby://localhost:#{port}")
      end

      def restart_action_cable
        ActionCable.server.restart
      end
    end
  end
end
