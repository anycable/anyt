# frozen_string_literal: true

feature "Stop streams" do
  channel do
    def subscribed
      stream_from "a"
      stream_from "b"
    end

    def ping(data)
      ActionCable.server.broadcast data["name"], {reply: "pong"}
    end

    def unfollow(data)
      stop_stream_from data["name"]
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
    Client unsubscribes from the stream
  ) do
    skip if Anyt.config.use_action_cable && (::ActionCable::VERSION::MAJOR < 6 || ::ActionCable::VERSION::MINOR < 1)

    ActionCable.server.broadcast("a", {data: "X"})

    msg = {"identifier" => {channel: channel}.to_json, "message" => {"data" => "X"}}

    assert_equal msg, client.receive

    perform_request = {
      :command => "message",
      :identifier => {channel: channel}.to_json,
      "data" => {"action" => "unfollow", "name" => "a"}.to_json
    }
    client.send(perform_request)
    sleep 0.2 # give some time to commit unsubscribe

    ActionCable.server.broadcast("a", {data: "Y"})
    sleep 0.2 # "a" should be broadcasted first
    ActionCable.server.broadcast("b", {data: "Z"})

    msg = {"identifier" => {channel: channel}.to_json, "message" => {"data" => "Z"}}
    assert_equal msg, client.receive
  end
end
