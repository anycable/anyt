# frozen_string_literal: true
describe "Basic subscription" do
  before do
    @client = Client.new(ignore: %w(ping welcome))
  end

  it "receives confirmation" do
    channel = "JustChannel"

    subscribe_request = { command: "subscribe", identifier: { channel: channel }.to_json }

    @client.send(subscribe_request)

    subscription_confirmation = {
      "identifier" => { channel: channel }.to_json, "type" => "confirm_subscription"
    }

    assert_equal subscription_confirmation, @client.receive
  end

  it "receives transmission" do
    channel = "TransmitSubscriptionChannel"

    subscribe_request = { command: "subscribe", identifier: { channel: channel }.to_json }

    @client.send(subscribe_request)

    transmission = { "identifier" => { channel: channel }.to_json, "message" => "hello" }

    assert_equal transmission, @client.receive

    subscription_confirmation = {
      "identifier" => { channel: channel }.to_json, "type" => "confirm_subscription"
    }

    assert_equal subscription_confirmation, @client.receive
  end
end
