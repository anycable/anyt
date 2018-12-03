# frozen_string_literal: true

require_relative "./application"

require_relative "../tests"

# Load channels from tests
Anyt::Tests.load_all_tests

Rails.application.initialize!

run Rails.application
