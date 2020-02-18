# frozen_string_literal: true

feature "Request" do
  connect_handler('reasons') do
    false
  end

  scenario %{
    Receives disconnect message when rejected
  } do
    client = build_client(qs: 'test=reasons')
    assert_equal(
      client.receive,
      "type" => "disconnect",
      "reconnect" => false,
      "reason" => "unauthorized"
    )

    client.wait_for_close
    assert client.closed?
  end
end
