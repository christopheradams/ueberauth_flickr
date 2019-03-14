defmodule UeberauthFlickr.Support.MockHTTPClient do
  @moduledoc """
  Mock HTTP client.
  """

  @behaviour Flickrex.Request.HttpClient

  @json_headers [{"content-type", "application/json; charset=utf-8"}]

  def request(method, url, body \\ "", headers \\ [], http_opts \\ []) do
    do_request(method, URI.parse(url), body, headers, http_opts)
  end

  def do_request(:get, %{path: "/services/oauth/request_token"} = _uri, _, _, _) do
    status = 200
    headers = []
    body = "oauth_callback_confirmed=true&oauth_token=TOKEN&oauth_token_secret=TOKEN_SECRET"

    {:ok, %{status_code: status, headers: headers, body: body}}
  end

  def do_request(:get, %{path: "/services/oauth/access_token"} = uri, _, _, _) do
    query = URI.decode_query(uri.query)

    {status, body} =
      case query["oauth_verifier"] do
        "BAD_VERIFIER" ->
          {400, "oauth_problem=parameter_absent&oauth_parameters_absent=oauth_callback"}

        _ ->
          {200,
           "fullname=FULL%20NAME&oauth_token=TOKEN&oauth_token_secret=SECRET&user_nsid=NSID&username=USERNAME"}
      end

    {:ok, %{status_code: status, headers: [], body: body}}
  end

  def do_request(:get, %{path: "/services/rest"} = uri, _, _, _) do
    query = URI.decode_query(uri.query)
    oauth_token = query["oauth_token"]

    body =
      cond do
        oauth_token != "TOKEN" ->
          """
          {"code": 98, "message": "Invalid auth token", "stat": "fail"}
          """

        true ->
          """
          {
            "user": {
              "id": "USERID",
              "nsid": "NSID",
              "username": {
                "_content": "USERNAME"
            }
            },
              "stat": "ok"
          }
          """
      end

    {:ok, %{status_code: 200, headers: @json_headers, body: body}}
  end
end
