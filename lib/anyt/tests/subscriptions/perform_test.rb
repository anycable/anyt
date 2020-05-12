# frozen_string_literal: true

require "anyt/utils"
using Anyt::AsyncHelpers

feature "Subscription perform methods" do
  channel do
    def tick
      transmit("tock")
    end

    def echo(data)
      transmit(response: data["text"])
    end
  end

  before do
    subscribe_request = {command: "subscribe", identifier: {channel: channel}.to_json}

    client.send(subscribe_request)

    ack = {
      "identifier" => {channel: channel}.to_json, "type" => "confirm_subscription"
    }

    assert_equal ack, client.receive
  end

  scenario %(
    Client perform actions without arguments
  ) do
    perform_request = {
      :command => "message",
      :identifier => {channel: channel}.to_json,
      "data" => {"action" => "tick"}.to_json
    }

    client.send(perform_request)

    msg = {"identifier" => {channel: channel}.to_json, "message" => "tock"}

    assert_equal msg, client.receive
  end

  scenario %(
    Client perform actions with arguments
  ) do
    perform_request = {
      :command => "message",
      :identifier => {channel: channel}.to_json,
      "data" => {"action" => "echo", "text" => "hello"}.to_json
    }

    client.send(perform_request)

    msg = {"identifier" => {channel: channel}.to_json, "message" => {"response" => "hello"}}

    assert_equal msg, client.receive
  end
end
