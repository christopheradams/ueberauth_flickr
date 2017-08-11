defmodule Ueberauth.Strategy.Flickr.OAuthTest do
  use ExUnit.Case, async: true

  alias Ueberauth.Strategy.Flickr.OAuth

  setup do
    Application.put_env :ueberauth, OAuth,
      consumer_key: "CONSUMER_KEY",
      consumer_secret: "CONSUMER_SECRET"
    :ok
  end

  test "access token" do
    {:ok, access_token} = OAuth.access_token("TOKEN", "SECRET", "VERIFIER")

    assert access_token ==
      %{fullname: "FULL NAME", oauth_token: "TOKEN",
        oauth_token_secret: "SECRET", user_nsid: "NSID",
        username: "USERNAME"}
  end

  test "access token!" do
    access_token = OAuth.access_token!("TOKEN", "SECRET", "VERIFIER")

    assert access_token ==
      %{fullname: "FULL NAME", oauth_token: "TOKEN",
        oauth_token_secret: "SECRET", user_nsid: "NSID",
        username: "USERNAME"}
  end

  test "authorize url" do
    auth_url = OAuth.authorize_url!("TOKEN")
    assert auth_url == "https://api.flickr.com/services/oauth/authorize?oauth_token=TOKEN"
  end

  test "get authorize url with perms" do
    auth_url = OAuth.authorize_url!("TOKEN", perms: "delete")
    assert auth_url == "https://api.flickr.com/services/oauth/authorize?oauth_token=TOKEN&perms=delete"
  end

  test "get info" do
    access_token =
      %{fullname: "FULL NAME", oauth_token: "TOKEN",
        oauth_token_secret: "SECRET", user_nsid: "NSID",
        username: "USERNAME"}

    {:ok, info} = OAuth.get_info(access_token)

    assert info == %{
      "stat" => "ok",
      "user" => %{
        "id" => "USERID",
        "nsid" => "NSID",
        "username" => %{
          "_content" => "USERNAME"
        }
      }
    }
  end

  test "request token" do
    {:ok, token} = OAuth.request_token(redirect_uri: "http://localhost/test")

    assert token == %{
      oauth_callback_confirmed: true,
      oauth_token: "TOKEN",
      oauth_token_secret: "TOKEN_SECRET"
    }
  end

  test "request token!" do
    token = OAuth.request_token!(redirect_uri: "http://localhost/test")

    assert token == %{
      oauth_callback_confirmed: true,
      oauth_token: "TOKEN",
      oauth_token_secret: "TOKEN_SECRET"
    }
  end
end
