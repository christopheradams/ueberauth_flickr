defmodule Ueberauth.Strategy.Flickr do
  @moduledoc """
  Flickr Strategy for Überauth.
  """

  use Ueberauth.Strategy, default_perms: nil

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  alias Ueberauth.Strategy.Flickr.OAuth

  @doc """
  Handles initial request for Flickr authentication
  """
  def handle_request!(conn) do
    perms = conn.params["perms"] || option(conn, :default_perms)

    params =
      case perms do
        nil -> []
        perms -> [perms: perms]
      end

    request = OAuth.request_token!(redirect_uri: callback_url(conn))

    conn
    |> put_session(:flickr_request, request)
    |> put_session(:flickr_perms, perms)
    |> redirect!(OAuth.authorize_url!(request.oauth_token, params))
  end

  @doc """
  Handles the callback from Flickr
  """
  def handle_callback!(%Plug.Conn{params: %{"oauth_verifier" => oauth_verifier}} = conn) do
    request = get_session(conn, :flickr_request)
    case OAuth.access_token(request.oauth_token, request.oauth_token_secret, oauth_verifier) do
      {:ok, access_token} -> fetch_user(conn, access_token)
      {:error, reason} -> set_errors!(conn, [error("access_error", reason)])
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:flickr_user, nil)
    |> put_private(:flickr_access, nil)
    |> put_session(:flickr_perms, nil)
    |> put_session(:flickr_request_token, nil)
    |> put_session(:flickr_request_token_secret, nil)
  end

  @doc """
  Fetches the uid field from the response
  """
  def uid(conn) do
    conn.private.flickr_access.user_nsid
  end

  @doc """
  Includes the credentials from the Flickr response
  """
  def credentials(conn) do
    token = conn.private.flickr_access.oauth_token
    secret = conn.private.flickr_access.oauth_token_secret
    perms = get_session(conn, :flickr_perms)

    %Credentials{token: token, secret: secret, scopes: [perms]}
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.flickr_user["person"]

    %Info{
      name: get_in(user, ["realname", "_content"]),
      nickname: get_in(user, ["username", "_content"]),
      description: get_in(user, ["description", "_content"]),
      location: get_in(user, ["location", "_content"]),
      urls: %{
        Flickr: get_in(user, ["photosurl", "_content"])
      }
    }
  end

  @doc """
  Stores the raw information (including the token) obtained from the Flickr callback
  """
  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.flickr_access,
        user: conn.private.flickr_user
      }
    }
  end

  defp fetch_user(conn, access_token) do
    case OAuth.get_info(access_token) do
      {:ok, person} ->
        conn
        |> put_private(:flickr_user, person)
        |> put_private(:flickr_access, access_token)
      {:error, reason} ->
        set_errors!(conn, [error("get_info", reason)])
    end
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end
end
