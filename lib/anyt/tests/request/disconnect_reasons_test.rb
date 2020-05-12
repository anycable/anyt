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
    assert_equal(
      client.receive,
      "type" => "disconnect",
      "reconnect" => false,
      "reason" => "unauthorized"
    )

    client.wait_for_close
    assert client.closed?
  end

  scenario %(
    Receives disconnect message when server restarts
  ) do
    client = build_client(
      qs: "test=reasons&reason=server_restart",
      ignore: %(ping)
    )

    assert_equal client.receive, "type" => "welcome"

    restart_server!

    assert_equal(
      client.receive,
      "type" => "disconnect",
      "reconnect" => true,
      "reason" => "server_restart"
    )
  end
end
