# frozen_string_literal: true

feature "Broadcast data from channel" do
  channel do
    def subscribed
      stream_from "a"
    end

    def speak(msg)
      ActionCable.server.broadcast "a", text: msg["msg"]
    end
  end

  let(:client2) { build_client(ignore: %w[ping welcome]) }

  before do
    subscribe_request = {command: "subscribe", identifier: {channel: channel}.to_json}

    client.send(subscribe_request)
    client2.send(subscribe_request)

    ack = {
      "identifier" => {channel: channel}.to_json, "type" => "confirm_subscription"
    }

    assert_equal ack, client.receive
    assert_equal ack, client2.receive
  end

  scenario %(
    Multiple clients receive messages from stream
  ) do
    perform_request = {
      :command => "message",
      :identifier => {channel: channel}.to_json,
      "data" => {"action" => "speak", "msg" => "hey there!"}.to_json
    }

    client.send(perform_request)

    msg = {
      "identifier" => {channel: channel}.to_json,
      "message" => {
        "text" => "hey there!"
      }
    }

    assert_equal msg, client.receive
    assert_equal msg, client2.receive
  end
end
