defmodule Ueberauth.Strategy.Flickr do
  @moduledoc """
  Flickr Strategy for Überauth.
  """

  use Ueberauth.Strategy

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra

  alias Ueberauth.Strategy

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

    request = Strategy.Flickr.OAuth.request_token!([], [redirect_uri: callback_url(conn)])

    conn
    |> put_session(:flickr_request_token, request.token)
    |> put_session(:flickr_request_token_secret, request.secret)
    |> redirect!(Strategy.Flickr.OAuth.authorize_url!(request, params))
  end

  @doc """
  Handles the callback from Flickr
  """
  def handle_callback!(%Plug.Conn{params: %{"oauth_verifier" => oauth_verifier}} = conn) do
    token = get_session(conn, :flickr_request_token)
    secret = get_session(conn, :flickr_request_token_secret)
    case Strategy.Flickr.OAuth.access_token({token, secret}, oauth_verifier) do
      {:ok, access_token} -> put_private(conn, :flickr_access_token, access_token)
      {:error, error} -> set_errors!(conn, [error(error.code, error.reason)])
    end
  end

  @doc false
  def handle_callback!(conn) do
    set_errors!(conn, [error("missing_code", "No code received")])
  end

  @doc false
  def handle_cleanup!(conn) do
    conn
    |> put_private(:flickr_access_token, nil)
    |> put_session(:flickr_request_token, nil)
    |> put_session(:flickr_request_token_secret, nil)
  end

  @doc """
  Fetches the uid field from the response
  """
  def uid(conn) do
    conn.private.flickr_access_token.user_nsid
  end

  @doc """
  Includes the credentials from the Flickr response
  """
  def credentials(conn) do
    token = conn.private.flickr_access_token.oauth_token
    secret = conn.private.flickr_access_token.oauth_token_secret

    %Credentials{token: token, secret: secret}
  end

  @doc """
  Fetches the fields to populate the info section of the `Ueberauth.Auth` struct.
  """
  def info(conn) do
    user = conn.private.flickr_access_token

    %Info{
      name: user.fullname,
      nickname: user.username,
      urls: %{
        Flickr: Flickrex.URL.url_photostream(user.user_nsid)
      }
    }
  end

  @doc """
  Stores the raw information (including the token) obtained from the Flickr callback
  """
  def extra(conn) do
    access_token = conn.private.flickr_access_token

    %Extra{
      raw_info: %{
        token: access_token
      }
    }
  end

  defp option(conn, key) do
    Keyword.get(options(conn), key, Keyword.get(default_options(), key))
  end
end
