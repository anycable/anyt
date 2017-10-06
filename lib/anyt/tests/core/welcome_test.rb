# frozen_string_literal: true

feature "Welcome" do
  scenario %{
    Client receives "welcome" message
  } do
    client = build_client
    assert_equal client.receive, "type" => "welcome"
  end
end
