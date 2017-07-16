# frozen_string_literal: true

describe "Ping message" do
  it "receives pings timestamps after connect" do
    client = Client.new(ignore: ["welcome"])

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
