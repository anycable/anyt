# frozen_string_literal: true

require_relative "./application"

require_relative "../tests"
require_relative "../remote_control"

# Start remote control
Anyt::RemoteControl::Server.start(Anyt.config.remote_control_port)

# Load channels from tests
Anyt::Tests.load_all_tests

Rails.application.initialize!

run Rails.application
