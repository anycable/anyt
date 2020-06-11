# frozen_string_literal: true

feature "Server restart" do
  connect_handler("reasons") do
    next false if request.params[:reason] == "unauthorized"
    true
  end

  scenario %(
    Client receives disconnect message
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
