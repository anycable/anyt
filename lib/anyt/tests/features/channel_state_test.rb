# frozen_string_literal: true

feature "Channel state" do
  channel do
    state_attr_accessor :user, :count

    def subscribed
      self.user = {name: params["name"]}
      self.count = 1

      stream_from "state_counts"
    end

    def tick
      self.count += 2
      transmit({count: count, name: user[:name]})
    end

    def unsubscribed
      return unless params["notify_disconnect"]

      ActionCable.server.broadcast("state_counts", {data: "user left: #{user[:name]}"})
    end
  end

  let(:identifier) { {channel: channel, name: "chipolino"}.to_json }

  let(:client2) { build_client(ignore: %w[ping welcome]) }
  let(:identifier2) { {channel: channel, name: "chipollone", notify_disconnect: true}.to_json }

  before do
    subscribe_request = {command: "subscribe", identifier: identifier}

    client.send(subscribe_request)

    ack = {
      "identifier" => identifier, "type" => "confirm_subscription"
    }

    assert_message ack, client.receive
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

    assert_message msg, client.receive
  end

  scenario %(
    Channel state is available in #unsubscribe callbacks
  ) do
    subscribe_request = {command: "subscribe", identifier: identifier2}

    client2.send(subscribe_request)

    ack = {
      "identifier" => identifier2, "type" => "confirm_subscription"
    }

    assert_message ack, client2.receive

    client2.close

    msg = {
      "identifier" => identifier,
      "message" => {"data" => "user left: chipollone"}
    }

    assert_message msg, client.receive
  end
end
