# frozen_string_literal: true

module Anycablebility
  # Loads and runs test cases
  module Tests
    require "anycablebility/client"
    require "minitest/spec"
    require "minitest/hell"
    require "minitest/reporters"

    class << self
      # Run all loaded tests
      def run
        Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

        Anycable.logger.debug "Run tests against: #{Anycablebility.config.target_url}"
        MiniTest.run
      end

      # Load all tests code
      #
      # NOTE: We should run this before launching RPC server
      def load_tests
        pattern = File.expand_path("tests/**/*.rb", __dir__)
        Dir.glob(pattern).each { |file| require file }
      end
    end
  end
end
