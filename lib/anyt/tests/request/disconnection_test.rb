# frozen_string_literal: true

feature "Request" do
  channel(:a) do
    def subscribed
      stream_from "request_a"
    end

    def unsubscribed
      ActionCable.server.broadcast("request_a", {data: "user left"})
    end
  end

  channel(:b) do
    def subscribed
      stream_from "request_b"
    end

    def unsubscribed
      ActionCable.server.broadcast("request_b", {data: "user left"})
    end
  end

  channel(:c) do
    def subscribed
      stream_from "request_c"
    end

    def unsubscribed
      ActionCable.server.broadcast("request_c", {data: "user left#{params[:id].presence}"})
    end
  end

  let(:client2) { build_client(ignore: %w[ping welcome]) }

  scenario %(
    Client disconnect invokes #unsubscribe callbacks
    for different channels
  ) do
    subscribe_request = {command: "subscribe", identifier: {channel: a_channel}.to_json}

    client.send(subscribe_request)

    ack = {
      "identifier" => {channel: a_channel}.to_json, "type" => "confirm_subscription"
    }

    assert_message ack, client.receive

    subscribe_request = {command: "subscribe", identifier: {channel: b_channel}.to_json}

    client.send(subscribe_request)

    ack = {
      "identifier" => {channel: b_channel}.to_json, "type" => "confirm_subscription"
    }

    assert_message ack, client.receive

    subscribe_request = {command: "subscribe", identifier: {channel: a_channel}.to_json}

    client2.send(subscribe_request)

    ack = {
      "identifier" => {channel: a_channel}.to_json, "type" => "confirm_subscription"
    }

    assert_message ack, client2.receive

    subscribe_request = {command: "subscribe", identifier: {channel: b_channel}.to_json}

    client2.send(subscribe_request)

    ack = {
      "identifier" => {channel: b_channel}.to_json, "type" => "confirm_subscription"
    }

    assert_message ack, client2.receive

    client2.close

    msg = {
      "identifier" => {channel: a_channel}.to_json,
      "message" => {"data" => "user left"}
    }
    msg2 = {
      "identifier" => {channel: b_channel}.to_json,
      "message" => {"data" => "user left"}
    }

    msgs = [client.receive, client.receive]

    assert_includes_message msgs, msg
    assert_includes_message msgs, msg2
  end

  scenario %(
    Client disconnect invokes #unsubscribe callbacks
    for multiple subscriptions from the same channel
  ) do
    subscribe_request = {command: "subscribe", identifier: {channel: c_channel}.to_json}

    client.send(subscribe_request)

    ack = {
      "identifier" => {channel: c_channel}.to_json, "type" => "confirm_subscription"
    }

    assert_message ack, client.receive

    subscribe_request = {command: "subscribe", identifier: {channel: c_channel, id: 1}.to_json}

    client2.send(subscribe_request)

    ack = {
      "identifier" => {channel: c_channel, id: 1}.to_json, "type" => "confirm_subscription"
    }

    assert_message ack, client2.receive

    subscribe_request = {command: "subscribe", identifier: {channel: c_channel, id: 2}.to_json}

    client2.send(subscribe_request)

    ack = {
      "identifier" => {channel: c_channel, id: 2}.to_json, "type" => "confirm_subscription"
    }

    assert_message ack, client2.receive

    client2.close

    msg = {
      "identifier" => {channel: c_channel}.to_json,
      "message" => {"data" => "user left1"}
    }

    msg2 = {
      "identifier" => {channel: c_channel}.to_json,
      "message" => {"data" => "user left2"}
    }

    msgs = [client.receive, client.receive]

    assert_includes_message msgs, msg
    assert_includes_message msgs, msg2
  end
end
