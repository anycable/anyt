# frozen_string_literal: true

module Anycablebility
  # Loads and runs test cases
  module Tests
    require "anycablebility/client"
    require "minitest/spec"
    require "minitest/hell"

    class << self
      def run
        load_tests
        MiniTest.run
      end

      private

      def load_tests
        pattern = File.expand_path("tests/**/*.rb", __dir__)
        Dir.glob(pattern).each { |file| require file }
      end
    end
  end
end
