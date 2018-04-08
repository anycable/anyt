# frozen_string_literal: true

feature "Subscription with params" do
  channel

  scenario %{
    Client subscribes to the same channel with different params
  } do

    subscribe_request = { command: "subscribe", identifier: { channel: channel, id: 1 }.to_json }

    client.send(subscribe_request)

    ack = {
      "identifier" => { channel: channel, id: 1 }.to_json, "type" => "confirm_subscription"
    }

    assert_equal ack, client.receive

    subscribe_request_2 = { command: "subscribe", identifier: { channel: channel, id: 2 }.to_json }

    client.send(subscribe_request_2)

    ack = {
      "identifier" => { channel: channel, id: 2 }.to_json, "type" => "confirm_subscription"
    }

    assert_equal ack, client.receive
  end
end
