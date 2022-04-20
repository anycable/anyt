# frozen_string_literal: true

feature "Streams with many clients" do
  channel do
    def subscribed
      stream_from "a"
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

    assert_message ack, client.receive
    assert_message ack, client2.receive
  end

  scenario %(
    Multiple clients receive messages from stream
  ) do
    ActionCable.server.broadcast("a", {data: "X"})

    msg = {"identifier" => {channel: channel}.to_json, "message" => {"data" => "X"}}

    assert_message msg, client.receive
    assert_message msg, client2.receive
  end

  scenario %(
    Client receive messages when another client removes subscription
  ) do
    ActionCable.server.broadcast("a", {data: "X"})

    msg = {"identifier" => {channel: channel}.to_json, "message" => {"data" => "X"}}

    assert_message msg, client.receive
    assert_message msg, client2.receive

    unsubscribe_request = {command: "unsubscribe", identifier: {channel: channel}.to_json}

    client.send(unsubscribe_request)

    # ActionCable doesn't provide an unsubscription ack :(
    sleep 1

    ActionCable.server.broadcast("a", {data: "Y"})

    msg2 = {"identifier" => {channel: channel}.to_json, "message" => {"data" => "Y"}}

    assert_message msg2, client2.receive
    assert_raises(Anyt::Client::TimeoutError) { client.receive(timeout: 0.5) }
  end
end
