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

  config.logger = Logger.new($stdout)
  config.log_level = AnyCable.config.log_level
  config.eager_load = true

  config.paths["config/routes.rb"] << File.join(__dir__, "routes.rb")
end

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    delegate :params, to: :request

    identified_by :uid

    def connect
      logger.debug "Connected"
      Anyt::ConnectHandlers.call(self)
    end

    def disconnect
      logger.debug "Disconnected"
    end
  end
end

module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end

ECHO_DELAY = ENV["ANYCABLE_BENCHMARK_ECHO_DELAY"].to_f

# BenchmarkChannel is useful when running Rails app only or RPC only
class BenchmarkChannel < ApplicationCable::Channel
  def subscribed
    stream_from "all#{stream_id}"
  end

  def echo(data)
    if ECHO_DELAY > 0
      sleep ECHO_DELAY
    end
    transmit data
  end

  def broadcast(data)
    ActionCable.server.broadcast "all#{stream_id}", data
    data["action"] = "broadcastResult"
    transmit data
  end


  def counter(data)
    num = data.fetch("num", 100).to_i
    num.times { ActionCable.server.broadcast "all", {text: "Count: #{_1}"} }
  end

  private

  def stream_id
    params[:id] || ""
  end
end

ActionCable.server.config.cable = {"adapter" => "redis"}
ActionCable.server.config.connection_class = -> { ApplicationCable::Connection }
ActionCable.server.config.disable_request_forgery_protection = true
ActionCable.server.config.logger =
  Rails.logger
