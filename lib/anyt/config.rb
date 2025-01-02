# frozen_string_literal: true

require "anyway"

module Anyt
  # Anyt configuration
  class Config < Anyway::Config
    attr_config :command,
      :only_tests,
      :except_tests,
      :filter_tests,
      :list_tests,
      :tests_relative_path,
      remote_control_port: 8919,
      use_action_cable: false,
      custom_action_cable: false,
      target_url: "ws://localhost:9292/cable",
      wait_command: 2,
      timeout_multiplier: 1

    coerce_types only_tests: {type: :string, array: true}
    coerce_types except_tests: {type: :string, array: true}

    def test_paths
      return unless tests_relative_path

      tests_relative_path.split(",").map do |path|
        File.expand_path(path, Dir.pwd)
      end
    end

    def filter_tests?
      only_tests || except_tests
    end

    def tests_filter
      only_rxp = /(#{only_tests.join("|")})/ if only_tests
      except_rxp = /(#{except_tests.join("|")})/ if except_tests

      @tests_filter ||= lambda do |path|
        (only_rxp.nil? || only_rxp.match?(path)) &&
          (except_rxp.nil? || !except_rxp.match?(path))
      end
    end

    def example_filter
      return unless filter_tests

      /#{filter_tests}/i
    end
  end
end
