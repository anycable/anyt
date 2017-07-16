# frozen_string_literal: true

class SimpleSubscribeTestChannel < ApplicationCable::Channel
end

class TransmitOnSubscribeTestChannel < ApplicationCable::Channel
  def subscribed
    transmit("hello")
    transmit("world")
  end
end

describe "#subscribe" do
  before do
    @client = Client.new(ignore: %w[ping welcome])
  end

  it "receives confirmation" do
    channel = "SimpleSubscribeTestChannel"

    subscribe_request = { command: "subscribe", identifier: { channel: channel }.to_json }

    @client.send(subscribe_request)

    subscription_confirmation = {
      "identifier" => { channel: channel }.to_json, "type" => "confirm_subscription"
    }

    assert_equal subscription_confirmation, @client.receive
  end

  it "receives transmissions" do
    channel = "TransmitOnSubscribeTestChannel"

    subscribe_request = { command: "subscribe", identifier: { channel: channel }.to_json }

    @client.send(subscribe_request)

    transmission = { "identifier" => { channel: channel }.to_json, "message" => "hello" }

    assert_equal transmission, @client.receive

    transmission = { "identifier" => { channel: channel }.to_json, "message" => "world" }

    assert_equal transmission, @client.receive

    subscription_confirmation = {
      "identifier" => { channel: channel }.to_json, "type" => "confirm_subscription"
    }

    assert_equal subscription_confirmation, @client.receive
  end
end
