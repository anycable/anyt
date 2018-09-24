# frozen_string_literal: true

feature "Request" do
  channel(:a) do
    def subscribed
      stream_from "a"
    end

    def unsubscribed
      ActionCable.server.broadcast("a", data: "user left#{params[:id].presence}")
    end
  end

  channel(:b) do
    def subscribed
      stream_from "b"
    end

    def unsubscribed
      ActionCable.server.broadcast("b", data: "user left")
    end
  end

  let(:client2) { build_client(ignore: %w[ping welcome]) }

  before do
    subscribe_request = { command: "subscribe", identifier: { channel: a_channel }.to_json }

    client.send(subscribe_request)

    ack = {
      "identifier" => { channel: a_channel }.to_json, "type" => "confirm_subscription"
    }

    assert_equal ack, client.receive

    subscribe_request = { command: "subscribe", identifier: { channel: b_channel }.to_json }

    client.send(subscribe_request)

    ack = {
      "identifier" => { channel: b_channel }.to_json, "type" => "confirm_subscription"
    }

    assert_equal ack, client.receive
  end

  scenario %{
    Client disconnect invokes #unsubscribe callbacks
    for different channels
  } do
    subscribe_request = { command: "subscribe", identifier: { channel: a_channel }.to_json }

    client2.send(subscribe_request)

    ack = {
      "identifier" => { channel: a_channel }.to_json, "type" => "confirm_subscription"
    }

    assert_equal ack, client2.receive

    subscribe_request = { command: "subscribe", identifier: { channel: b_channel }.to_json }

    client2.send(subscribe_request)

    ack = {
      "identifier" => { channel: b_channel }.to_json, "type" => "confirm_subscription"
    }

    assert_equal ack, client2.receive

    client2.close

    msg = {
      "identifier" => { channel: a_channel }.to_json,
      "message" => { "data" => "user left" }
    }
    msg2 = {
      "identifier" => { channel: b_channel }.to_json,
      "message" => { "data" => "user left" }
    }

    msgs = [client.receive, client.receive]

    assert_includes msgs, msg
    assert_includes msgs, msg2
  end

  scenario %{
    Client disconnect invokes #unsubscribe callbacks
    for multiple subscriptions from the same channel
  } do
    subscribe_request = { command: "subscribe", identifier: { channel: a_channel, id: 1 }.to_json }

    client2.send(subscribe_request)

    ack = {
      "identifier" => { channel: a_channel, id: 1 }.to_json, "type" => "confirm_subscription"
    }

    assert_equal ack, client2.receive

    subscribe_request = { command: "subscribe", identifier: { channel: a_channel, id: 2 }.to_json }

    client2.send(subscribe_request)

    ack = {
      "identifier" => { channel: a_channel, id: 2 }.to_json, "type" => "confirm_subscription"
    }

    assert_equal ack, client2.receive

    client2.close

    msg = {
      "identifier" => { channel: a_channel }.to_json,
      "message" => { "data" => "user left1" }
    }

    msg2 = {
      "identifier" => { channel: a_channel }.to_json,
      "message" => { "data" => "user left2" }
    }

    msgs = [client.receive, client.receive]

    assert_includes msgs, msg
    assert_includes msgs, msg2
  end
end
