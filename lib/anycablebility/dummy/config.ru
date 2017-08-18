# frozen_string_literal: true

require_relative "./application"

require_relative "../tests"

# Load channels from tests
Anycablebility::Tests.load_all_tests

run ActionCable.server
