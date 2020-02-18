# frozen_string_literal: true

feature "Request" do
  connect_handler('request_url') do
    request.url =~ /test=request_url/
  end

  scenario %{
    Url is set during connection
  } do
    client = build_client(qs: 'test=request_url')
    assert_equal client.receive, "type" => "welcome"
  end

  connect_handler('cookies') do
    cookies[:username] == 'john green'
  end

  scenario %{
    Reject when required cookies are not set
  } do
    client = build_client(qs: 'test=cookies')
    client.wait_for_close
    assert client.closed?
  end

  scenario %{
    Accepts when required cookies are set
  } do
    client = build_client(qs: 'test=cookies', cookies: 'username=john green')
    assert_equal client.receive, "type" => "welcome"
  end

  connect_handler('headers') do
    request.headers['X-API-TOKEN'] == 'abc'
  end

  scenario %{
    Reject when required header is missing
  } do
    client = build_client(qs: 'test=headers')
    client.wait_for_close
    assert client.closed?
  end

  scenario %{
    Accepts when required header is set
  } do
    client = build_client(qs: 'test=headers', headers: { 'x-api-token' => 'abc' })
    assert_equal client.receive, "type" => "welcome"
  end
end
