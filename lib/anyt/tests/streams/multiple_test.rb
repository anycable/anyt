# frozen_string_literal: true

feature "Multiple streams" do
  channel do
    def subscribed
      stream_from "a"
      stream_from "b"
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
    Client receives messages from both streams
  ) do
    ActionCable.server.broadcast("a", data: "X")

    msg = {"identifier" => {channel: channel}.to_json, "message" => {"data" => "X"}}

    assert_equal msg, client.receive

    ActionCable.server.broadcast("b", data: "Y")

    msg = {"identifier" => {channel: channel}.to_json, "message" => {"data" => "Y"}}

    assert_equal msg, client.receive
  end

  scenario %(
    Client does not receive messages from any stream after removing subscription
  ) do
    ActionCable.server.broadcast("a", data: "X")

    msg = {"identifier" => {channel: channel}.to_json, "message" => {"data" => "X"}}

    assert_equal msg, client.receive

    unsubscribe_request = {command: "unsubscribe", identifier: {channel: channel}.to_json}

    client.send(unsubscribe_request)

    # ActionCable doesn't provide an unsubscription ack :(
    sleep 1

    ActionCable.server.broadcast("a", data: "Y")
    ActionCable.server.broadcast("b", data: "Z")

    assert_raises(Anyt::Client::TimeoutError) { client.receive(timeout: 0.5) }
  end
end
