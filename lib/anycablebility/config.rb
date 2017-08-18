# frozen_string_literal: true

require "anyway"

module Anycablebility
  # Anycablebility configuration
  class Config < Anyway::Config
    attr_config :command,
                :only_tests,
                target_url: "ws://localhost:9292/",
                wait_command: 2

    def filter_tests?
      !only_tests.nil?
    end

    def tests_filter
      @tests_filter ||= begin
        %r{(#{only_tests.join('|')})}
      end
    end
  end
end
