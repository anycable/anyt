# frozen_string_literal: true

module Anycablebility
  module AsyncHelpers # :nodoc:
    refine Object do
      # Wait for block to return true of raise error
      def wait(timeout = 1)
        until yield
          sleep 0.1
          timeout -= 0.1
          raise "Timeout error" unless timeout.positive?
        end
      end
    end
  end
end
