# frozen_string_literal: true

require "anyway"

module Anyt
  # Anyt configuration
  class Config < Anyway::Config
    attr_config :command,
                :only_tests,
                :tests_relative_path,
                target_url: "ws://localhost:9292/cable",
                wait_command: 2

    def tests_path
      return unless tests_relative_path

      File.expand_path(tests_relative_path, Dir.pwd)
    end

    def filter_tests?
      !only_tests.nil?
    end

    def tests_filter
      @tests_filter ||= begin
        /(#{only_tests.join('|')})/
      end
    end
  end
end
