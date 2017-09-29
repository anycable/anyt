# frozen_string_literal: true

module Anycablebility
  # Loads and runs test cases
  module Tests
    require "anycablebility/client"
    require_relative "ext/minitest"

    class << self
      # Run all loaded tests
      def run
        Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

        Anycable.logger.debug "Run tests against: #{Anycablebility.config.target_url}"
        Minitest.run
      end

      # Load tests code (filtered if present)
      #
      # NOTE: We should run this before launching RPC server

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def load_tests
        return load_all_tests unless Anycablebility.config.filter_tests?

        pattern = File.expand_path("tests/**/*.rb", __dir__)
        skipped = []
        filter = Anycablebility.config.tests_filter

        Dir.glob(pattern).each do |file|
          if file.match?(filter)
            require file
          else
            skipped << file.gsub(File.join(__dir__, 'tests/'), '').gsub('_test.rb', '')
          end
        end

        $stdout.print "Skipping tests: #{skipped.join(', ')}\n"
      end

      # Load all test files
      def load_all_tests
        pattern = File.expand_path("tests/**/*.rb", __dir__)

        Dir.glob(pattern).each { |file| require file }
      end
    end
  end
end
