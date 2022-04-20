# frozen_string_literal: true

feature "Request" do
  connect_handler("reasons") do
    next false if request.params[:reason] == "unauthorized"
    true
  end

  scenario %(
    Receives disconnect message when rejected
  ) do
    client = build_client(qs: "test=reasons&reason=unauthorized")
    assert_message(
      {
        "type" => "disconnect",
        "reconnect" => false,
        "reason" => "unauthorized"
      },
      client.receive,
    )

    client.wait_for_close
    assert client.closed?
  end
end
