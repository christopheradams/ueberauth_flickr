defmodule Ueberauth.Strategy.Flickr.OAuthTest do
  use ExUnit.Case, async: true

  alias Flickrex.Client
  alias Flickrex.Schema

  alias Ueberauth.Strategy.Flickr.OAuth

  setup do
    Application.put_env :ueberauth, OAuth,
      consumer_key: "consumer_key",
      consumer_secret: "consumer_secret"
    :ok
  end

  test "access token" do
    assert {:ok, %Schema.Access{}} = OAuth.access_token(%Client.Request{}, nil)
  end

  test "access token!" do
    assert %Schema.Access{} = OAuth.access_token!(%Client.Request{}, nil)
  end

  test "authorize url" do
    auth_url = OAuth.authorize_url!(%Client.Request{})
    assert auth_url == "https://api.flickr.com/services/oauth/authorize?oauth_token="
  end

  test "get authorize url with perms" do
    auth_url = OAuth.authorize_url!(%Client.Request{}, perms: "delete")
    assert auth_url == "https://api.flickr.com/services/oauth/authorize?oauth_token=&perms=delete"
  end

  test "get info" do
    assert {:ok, _info} = OAuth.get_info(%Schema.Access{})
  end

  test "request token" do
    token = OAuth.request_token([], [redirect_uri: "http://localhost/test"])
    assert {:ok, %Client.Request{}} = token
  end

  test "request token!" do
    token = OAuth.request_token!([], [redirect_uri: "http://localhost/test"])
    assert %Client.Request{} = token
  end
end
