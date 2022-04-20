# frozen_string_literal: true

feature "Subscription aknowledgement" do
  channel

  channel("rejector") do
    def subscribed
      reject
    end
  end

  scenario %(
    Client receives subscription confirmation
  ) do
    subscribe_request = {command: "subscribe", identifier: {channel: channel}.to_json}

    client.send(subscribe_request)

    ack = {
      "identifier" => {channel: channel}.to_json, "type" => "confirm_subscription"
    }

    assert_message ack, client.receive
  end

  scenario %(
    Client receives subscription rejection
  ) do
    subscribe_request = {command: "subscribe", identifier: {channel: rejector_channel}.to_json}

    client.send(subscribe_request)

    ack = {
      "identifier" => {channel: rejector_channel}.to_json, "type" => "reject_subscription"
    }

    assert_message ack, client.receive
  end
end
