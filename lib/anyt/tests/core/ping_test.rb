# frozen_string_literal: true

feature "Ping" do
  scenario %{
    Client receives pings with timestamps
  } do
    client = build_client(ignore: ["welcome"])

    previous_stamp = 0

    2.times do
      ping = client.receive

      current_stamp = ping["message"]

      assert_equal ping["type"], "ping"
      assert_kind_of Integer, current_stamp
      refute_operator previous_stamp, :>=, current_stamp

      previous_stamp = current_stamp
    end
  end
end
