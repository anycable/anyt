# frozen_string_literal: true

describe "Welcome message" do
  it "receives welcome on connect" do
    client = Client.new
    assert_equal client.receive, "type" => "welcome"
  end
end
