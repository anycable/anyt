# frozen_string_literal: true

require "rails"
require "action_controller/railtie"
require "action_cable/engine"

require "redis"
require "anycable-rails"

require "action_dispatch/middleware/cookies"

class TestApp < Rails::Application
  secrets.secret_token = "secret_token"
  secrets.secret_key_base = "secret_key_base"

  config.logger = Logger.new(STDOUT)
  config.log_level = AnyCable.config.log_level
  config.eager_load = true

  config.paths["config/routes.rb"] << File.join(__dir__, "routes.rb")
end

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    delegate :params, to: :request

    def connect
      logger.info "Connected"
      Anyt::ConnectHandlers.call(self)
    end

    def disconnect
      logger.info "Disconnected"
    end
  end
end

module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end

ActionCable.server.config.cable = {"adapter" => "redis"}
ActionCable.server.config.connection_class = -> { ApplicationCable::Connection }
ActionCable.server.config.disable_request_forgery_protection = true
ActionCable.server.config.logger =
  Rails.logger = Logger.new(STDOUT).tap { |l| l.level = Logger::DEBUG }
