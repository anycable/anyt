# frozen_string_literal: true

feature "Subscription transmissions" do
  channel do
    def subscribed
      transmit("hello")
      transmit("world")
    end
  end

  scenario %{
    Client receives transmissions from #subscribed callback
  } do

    subscribe_request = { command: "subscribe", identifier: { channel: channel }.to_json }

    client.send(subscribe_request)

    msg = { "identifier" => { channel: channel }.to_json, "message" => "hello" }

    assert_equal msg, client.receive

    msg = { "identifier" => { channel: channel }.to_json, "message" => "world" }

    assert_equal msg, client.receive

    ack = {
      "identifier" => { channel: channel }.to_json, "type" => "confirm_subscription"
    }

    assert_equal ack, client.receive
  end
end
