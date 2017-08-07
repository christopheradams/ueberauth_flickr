defmodule Ueberauth.Strategy.Flickr.OAuth do
  @moduledoc """
  OAuth1 for Flickr.

  Add `consumer_key` and `consumer_secret` to your configuration:

  config :ueberauth, Ueberauth.Strategy.Flickr.OAuth,
    consumer_key: System.get_env("FLICKR_CONSUMER_KEY"),
    consumer_secret: System.get_env("FLICKR_CONSUMER_SECRET"),
    redirect_uri: System.get_env("FLICKR_REDIRECT_URI")
  """

  def access_token(token, secret, verifier, opts \\ []) do
    config = config(opts)

    operation = Flickrex.Auth.access_token(token, secret, verifier)
    response = Flickrex.request(operation, config)

    case response do
      {:ok, %{body: body}} ->
        {:ok, body}
      error ->
        error
    end
  end

  def access_token!(token, secret, verifier, opts \\ []) do
    case access_token(token, secret, verifier, opts) do
      {:ok, token} ->
        token
      error ->
        raise RuntimeError, """
        UeberauthFlickr Error

        #{inspect error}
        """
    end
  end

  def authorize_url!(token, params \\ []) do
    token
    |> Flickrex.Auth.authorize_url(params)
    |> Flickrex.request!()
  end

  def get_info(access_token) do
    params = [user_id: access_token.user_nsid]

    response =
      params
      |> Flickrex.Flickr.People.get_info()
      |> Flickrex.request(access_token)

    case response do
      {:ok, %{body: body}} ->
        {:ok, body}
      error ->
        error
    end
  end

  defp config(opts) do
    Keyword.merge(Application.get_env(:ueberauth, __MODULE__), opts)
  end

  def request_token(opts \\ []) do
    config = config(opts)
    params = [oauth_callback: config[:redirect_uri]]

    response =
      params
      |> Flickrex.Auth.request_token()
      |> Flickrex.request(config)

    case response do
      {:ok, %{body: body}} ->
        {:ok, body}
      error ->
        error
    end
  end

  def request_token!(opts \\ []) do
    case request_token(opts) do
      {:ok, token} ->
        token
      error ->
        raise RuntimeError, """
        UeberauthFlickr Error

        #{inspect error}
        """
    end
  end
end
