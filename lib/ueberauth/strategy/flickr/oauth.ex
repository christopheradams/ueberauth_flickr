defmodule Ueberauth.Strategy.Flickr.OAuth do
  @moduledoc """
  OAuth1 for Flickr.

  Add `consumer_key` and `consumer_secret` to your configuration:

  config :ueberauth, Ueberauth.Strategy.Flickr.OAuth,
    consumer_key: System.get_env("FLICKR_CONSUMER_KEY"),
    consumer_secret: System.get_env("FLICKR_CONSUMER_SECRET"),
    redirect_uri: System.get_env("FLICKR_REDIRECT_URI")
  """

  def access_token({token, token_secret}, verifier, _opts \\ []) do
    Flickrex.fetch_access_token(client(), token, token_secret, verifier)
  end

  def access_token!(access_token, verifier, opts \\ []) do
    case access_token(access_token, verifier, opts) do
      {:ok, token} -> token
      {:error, error} -> raise error
    end
  end

  def authorize_url!(token, params \\ []) do
    Flickrex.get_authorize_url(token, params)
  end

  defp client do
    Flickrex.new(config())
  end

  defp config(opts \\ []) do
    Keyword.merge(Application.get_env(:ueberauth, __MODULE__), opts)
  end

  def request_token(params \\ [], opts \\ []) do
    config = config(opts)
    oauth_callback = Keyword.get(opts, :redirect_uri, config[:redirect_uri])
    params = [{:oauth_callback, oauth_callback} | params]

    Flickrex.fetch_request_token(client(), params)
  end

  def request_token!(params \\ [], opts \\ []) do
    case request_token(params, opts) do
      {:ok, token} -> token
      {:error, error} -> raise error
    end
  end
end
