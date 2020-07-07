# frozen_string_literal: true

feature "Single stream" do
  channel do
    def subscribed
      stream_from "a"
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
    Client receives messages from the stream
  ) do
    ActionCable.server.broadcast("a", data: "X")

    msg = {"identifier" => {channel: channel}.to_json, "message" => {"data" => "X"}}

    assert_equal msg, client.receive

    ActionCable.server.broadcast("a", data: "Y")

    msg = {"identifier" => {channel: channel}.to_json, "message" => {"data" => "Y"}}

    assert_equal msg, client.receive
  end

  scenario %(
    Client does not receive messages from the stream after removing subscription
  ) do
    ActionCable.server.broadcast("a", data: "X")

    msg = {"identifier" => {channel: channel}.to_json, "message" => {"data" => "X"}}

    assert_equal msg, client.receive

    unsubscribe_request = {command: "unsubscribe", identifier: {channel: channel}.to_json}

    client.send(unsubscribe_request)

    # ActionCable doesn't provide an unsubscription ack :(
    sleep 1

    ActionCable.server.broadcast("a", data: "Y")

    assert_raises(Anyt::Client::TimeoutError) { client.receive(timeout: 0.5) }
  end

  scenario %(
    Client receives multiple messages when subscribed to the same channel
    with different params
  ) do
    subscribe_request = {command: "subscribe", identifier: {channel: channel, some_param: "test"}.to_json}

    client.send(subscribe_request)

    ack = {
      "identifier" => {channel: channel, some_param: "test"}.to_json, "type" => "confirm_subscription"
    }

    assert_equal ack, client.receive

    ActionCable.server.broadcast("a", data: "XX")

    msg = {"identifier" => {channel: channel}.to_json, "message" => {"data" => "XX"}}
    msg2 = {"identifier" => {channel: channel, some_param: "test"}.to_json, "message" => {"data" => "XX"}}

    received = client.receive, client.receive

    assert_includes received, msg
    assert_includes received, msg2
  end
end
