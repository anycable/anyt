# frozen_string_literal: true

feature "Broadcast data to stream" do
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

    assert_message ack, client.receive
  end

  scenario %(
    Broadcast object
  ) do
    ActionCable.server.broadcast(
      "a",
      {data: {user_id: 1, status: "left", meta: {connection_time: "10s"}}}
    )

    msg = {
      "identifier" => {channel: channel}.to_json,
      "message" => {
        "data" => {"user_id" => 1, "status" => "left", "meta" => {"connection_time" => "10s"}}
      }
    }

    assert_message msg, client.receive
  end

  scenario %(
    Broadcast custom string
  ) do
    ActionCable.server.broadcast("a", "<script>alert('Message!');</script>")

    msg = {
      "identifier" => {channel: channel}.to_json,
      "message" => "<script>alert('Message!');</script>"
    }

    assert_message msg, client.receive
  end

  scenario %(
    Broadcast JSON string
  ) do
    ActionCable.server.broadcast("a", '{"script":{"alert":"Message!"}}')

    msg = {
      "identifier" => {channel: channel}.to_json,
      "message" => '{"script":{"alert":"Message!"}}'
    }

    assert_message msg, client.receive
  end
end
