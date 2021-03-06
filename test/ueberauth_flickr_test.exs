defmodule UeberauthFlickrTest do
  use ExUnit.Case
  use Plug.Test

  alias Plug.Session

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
    assert get_session(conn, :flickr_request) == %{
             oauth_callback_confirmed: true,
             oauth_token: "TOKEN",
             oauth_token_secret: "TOKEN_SECRET"
           }

    assert get_session(conn, :flickr_perms) == nil
  end

  @tag path: "/auth/flickr?perms=delete"
  test "handle request perms", %{conn: conn} do
    assert get_session(conn, :flickr_request) == %{
             oauth_callback_confirmed: true,
             oauth_token: "TOKEN",
             oauth_token_secret: "TOKEN_SECRET"
           }

    assert get_session(conn, :flickr_perms) == "delete"
  end

  @tag path: "/auth/flickr/callback?oauth_verifier=VERIFER",
       request: %{oauth_token: "TOKEN", oauth_token_secret: "SECRET"}
  test "handle callback", %{conn: %{assigns: %{ueberauth_auth: auth}}} do
    assert %Ueberauth.Auth{} = auth

    assert auth.extra.raw_info[:token] == %{
             fullname: "FULL NAME",
             oauth_token: "TOKEN",
             oauth_token_secret: "SECRET",
             user_nsid: "NSID",
             username: "USERNAME"
           }
  end

  @tag path: "/auth/flickr/callback?oauth_verifier=BAD_VERIFIER",
       request: %{oauth_token: "TOKEN", oauth_token_secret: "SECRET"}
  test "handle callback with bad verifier", %{conn: %{assigns: %{ueberauth_failure: failure}}} do
    assert failure.errors |> List.first() |> Map.get(:message_key) == "access_error"
  end

  @tag path: "/auth/flickr/callback"
  test "handle callback with no code", %{conn: %{assigns: assigns}} do
    assert %Ueberauth.Failure{} = assigns[:ueberauth_failure]
  end
end
