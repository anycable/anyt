# frozen_string_literal: true

require "rails"
require "action_cable"

module ApplicationCable
  class Connection < ActionCable::Connection::Base
  end
end

module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end

pattern = File.expand_path("channels/**/*.rb", __dir__)

Dir.glob(pattern).each { |file| require file }

ActionCable.server.config.connection_class = -> { ApplicationCable::Connection }
ActionCable.server.config.disable_request_forgery_protection = true
ActionCable.server.config.logger = Rails.logger = Logger.new(STDOUT)
