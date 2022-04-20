# frozen_string_literal: true

feature "Remote disconnect" do
  connect_handler("uid") do
    self.uid = request.params["uid"]
    uid.present?
  end

  scenario %(
   Close single connection by id
  ) do
    client = build_client(qs: "test=uid&uid=26", ignore: %w[ping])
    assert_message({"type" => "welcome"}, client.receive)

    # Prevent race conditions when we send disconnect before internal channel subscription has been made
    # (only for Action Cable)
    sleep 1
    ActionCable.server.remote_connections.where(uid: "26").disconnect

    # Waiting for https://github.com/rails/rails/pull/39544
    unless Anyt.config.use_action_cable
      assert_message(
        {
          "type" => "disconnect",
          "reconnect" => true,
          "reason" => "remote"
        },
        client.receive,
      )
    end

    client.wait_for_close
    assert client.closed?
  end
end
