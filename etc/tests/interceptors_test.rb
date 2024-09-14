# frozen_string_literal: true

feature "Streams" do
  channel do
    def subscribed
      transformer = params[:transformer].to_sym

      stream_from "a", coder: ActiveSupport::JSON do |message|
        message["text"] = message["text"].send(transformer)
        transmit(message)
      end

      # No coder
      stream_from "b" do |message|
        # transmit as is
        transmit(message)
      end

      # No interceptor
      stream_from "c"
    end
  end

  let(:client2) { build_client(ignore: %w[ping welcome]) }

  before do
    @identifier = {channel:, transformer: "reverse"}.to_json

    subscribe_request = {command: "subscribe", identifier: @identifier}

    client.send(subscribe_request)

    ack = {
      "identifier" => @identifier, "type" => "confirm_subscription"
    }

    assert_message ack, client.receive

    @identifier2 = {channel:, transformer: "upcase"}.to_json

    subscribe_request = {command: "subscribe", identifier: @identifier2}

    client2.send(subscribe_request)

    ack = {
      "identifier" => @identifier2, "type" => "confirm_subscription"
    }

    assert_message ack, client2.receive
  end

  scenario %(
    Intercept with coder
  ) do
    ActionCable.server.broadcast("a", {text: "cable"})

    msg = {
      "identifier" => @identifier,
      "message" => {"text" => "elbac"}
    }

    assert_message msg, client.receive

    msg = {
      "identifier" => @identifier2,
      "message" => {"text" => "CABLE"}
    }

    assert_message msg, client2.receive
  end

  scenario %(
    Intercept without coder
  ) do
    ActionCable.server.broadcast("b", {text: "cable"})

    msg = {
      "identifier" => @identifier,
      "message" => {"text" => "cable"}.to_json
    }

    assert_message msg, client.receive

    msg = {
      "identifier" => @identifier2,
      "message" => {"text" => "cable"}.to_json
    }

    assert_message msg, client2.receive

    ActionCable.server.broadcast("c", {text: "cable"})

    msg = {
      "identifier" => @identifier,
      "message" => {"text" => "cable"}
    }

    assert_message msg, client.receive

    msg = {
      "identifier" => @identifier2,
      "message" => {"text" => "cable"}
    }

    assert_message msg, client2.receive
  end
end
