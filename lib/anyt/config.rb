# frozen_string_literal: true

require "anyway"

module Anyt
  # Anyt configuration
  class Config < Anyway::Config
    attr_config :command,
      :only_tests,
      :except_tests,
      :tests_relative_path,
      remote_control_port: 8919,
      use_action_cable: false,
      target_url: "ws://localhost:9292/cable",
      wait_command: 2,
      timeout_multiplier: 1

    coerce_types only_tests: {type: :string, array: true}
    coerce_types except_tests: {type: :string, array: true}

    def tests_path
      return unless tests_relative_path

      File.expand_path(tests_relative_path, Dir.pwd)
    end

    def filter_tests?
      only_tests || except_tests
    end

    def tests_filter
      only_rxp = /(#{only_tests.join('|')})/ if only_tests
      except_rxp = /(#{except_tests.join('|')})/ if except_tests

      @tests_filter ||= lambda do |path|
        (only_rxp.nil? || only_rxp.match?(path)) &&
          (except_rxp.nil? || !except_rxp.match?(path))
      end
    end
  end
end
