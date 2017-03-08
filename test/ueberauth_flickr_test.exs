defmodule UeberauthFlickrTest do
  use ExUnit.Case
  use Plug.Test

  alias Plug.Session
  alias Flickrex.Client

  @session_opts [
    store: :cookie,
    key: "foobar",
    encryption_salt: "encrypted cookie salt",
    signing_salt: "signing salt",
    log: false,
    encrypt: false
  ]

  @secret String.duplicate("abcdef0123456789", 8)

  setup(%{path: path} = context) do
    conn =
      conn(:get, path)
      |> Map.put(:secret_key_base, @secret)
      |> Session.call(Session.init(@session_opts))
      |> fetch_session
      |> fetch_query_params
      |> put_session(:flickr_request, context[:request])
      |> Ueberauth.call(Ueberauth.init([]))
    [conn: conn]
  end

  @tag path: "/auth/flickr"
  test "handle request", %{conn: conn} do
    assert %Client.Request{} = get_session(conn, :flickr_request)
    assert get_session(conn, :flickr_perms) == nil
  end

  @tag path: "/auth/flickr?perms=delete"
  test "handle request perms", %{conn: conn} do
    assert %Client.Request{} = get_session(conn, :flickr_request)
    assert get_session(conn, :flickr_perms) == "delete"
  end

  @tag path: "/auth/flickr/callback?oauth_verifier=VERIFER", request: %Client.Request{}
  test "handle callback", %{conn: %{assigns: %{ueberauth_auth: auth}}} do
    assert %Ueberauth.Auth{} = auth
    assert %Flickrex.Schema.Access{} = auth.extra.raw_info[:token]
  end

  @tag path: "/auth/flickr/callback"
  test "handle callback with no code", %{conn: %{assigns: assigns}} do
    assert %Ueberauth.Failure{} = assigns[:ueberauth_failure]
  end
end
