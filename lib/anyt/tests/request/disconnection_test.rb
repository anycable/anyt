# frozen_string_literal: true

feature "Request" do
  channel(:a) do
    def subscribed
      stream_from "a"
    end

    def unsubscribed
      ActionCable.server.broadcast("a", data: "user left")
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
    [client, client2].each do |client_|
      subscribe_request = { command: "subscribe", identifier: { channel: a_channel }.to_json }

      client_.send(subscribe_request)

      ack = {
        "identifier" => { channel: a_channel }.to_json, "type" => "confirm_subscription"
      }

      assert_equal ack, client_.receive

      subscribe_request = { command: "subscribe", identifier: { channel: b_channel }.to_json }

      client_.send(subscribe_request)

      ack = {
        "identifier" => { channel: b_channel }.to_json, "type" => "confirm_subscription"
      }

      assert_equal ack, client_.receive
    end
  end

  scenario %{
    Client disconnect invokes #unsubscribe callbacks
  } do

    client2.close

    msg = { "identifier" => { channel: a_channel }.to_json, "message" => { "data" => "user left" } }
    msg2 = { "identifier" => { channel: b_channel }.to_json, "message" => { "data" => "user left" } }

    msgs = [client.receive, client.receive]

    assert_includes msgs, msg
    assert_includes msgs, msg2
  end
end
