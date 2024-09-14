# frozen_string_literal: true

feature "Subscriptions" do
  channel do
    periodically :transmit_progress, every: 1.second

    state_attr_accessor :progress

    def subscribed
      self.progress = 0
    end

    def transmit_progress
      self.progress += 1

      transmit({progress:})
    end
  end

  before do
    @identifier = {channel:}.to_json

    subscribe_request = {command: "subscribe", identifier: @identifier}

    client.send(subscribe_request)

    ack = {
      "identifier" => @identifier, "type" => "confirm_subscription"
    }

    assert_message ack, client.receive
  end

  scenario %(
    Periodic timers
  ) do
    msg = client.receive
    assert_equal 1, msg["message"]["progress"]

    msg = client.receive
    assert_equal 2, msg["message"]["progress"]
  end
end
