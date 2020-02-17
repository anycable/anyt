# frozen_string_literal: true

feature "Request" do
  channel do
    delegate :params, to: :connection

    def subscribed
      reject unless params[:token] == "secret"
    end
  end

  scenario %{
    Channel has access to request
  } do

    client = build_client(qs: "token=secret", ignore: %w[ping])
    assert_equal client.receive, "type" => "welcome"

    subscribe_request = { command: "subscribe", identifier: { channel: channel }.to_json }

    client.send(subscribe_request)

    ack = {
      "identifier" => { channel: channel }.to_json, "type" => "confirm_subscription"
    }

    assert_equal ack, client.receive
  end
end
