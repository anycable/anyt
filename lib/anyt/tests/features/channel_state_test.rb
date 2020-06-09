# frozen_string_literal: true

feature "Channel state" do
  channel do
    state_attr_accessor :user, :count

    def subscribed
      self.user = {name: params["name"]}
      self.count = 1
    end

    def tick
      self.count += 2
      transmit(count: count, name: user[:name])
    end
  end

  let(:identifier) { {channel: channel, name: "chipolino"}.to_json }

  before do
    subscribe_request = {command: "subscribe", identifier: identifier}

    client.send(subscribe_request)

    ack = {
      "identifier" => identifier, "type" => "confirm_subscription"
    }

    assert_equal ack, client.receive
  end

  scenario %(
    Channel state is kept between commands
  ) do
    perform_request = {
      :command => "message",
      :identifier => identifier,
      "data" => {"action" => "tick"}.to_json
    }

    client.send(perform_request)

    msg = {"identifier" => identifier, "message" => {"count" => 3, "name" => "chipolino"}}

    assert_equal msg, client.receive
  end
end
