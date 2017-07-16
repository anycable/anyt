# frozen_string_literal: true

require "rails"
require "action_cable"

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    def connect
      logger.info "Connected"
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

ActionCable.server.config.connection_class = -> { ApplicationCable::Connection }
ActionCable.server.config.disable_request_forgery_protection = true
ActionCable.server.config.logger =
  Rails.logger = Logger.new(STDOUT).tap { |l| l.level = Logger::DEBUG }
