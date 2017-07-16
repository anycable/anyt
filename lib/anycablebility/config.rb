# frozen_string_literal: true

require "anyway"

module Anycablebility
  # Anycablebility configuration
  class Config < Anyway::Config
    attr_config :command,
                target_url: "ws://localhost:9292/",
                wait_command: 2
  end
end
