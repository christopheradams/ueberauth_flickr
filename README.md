# Überauth Flickr

> Flickr strategy for Überauth.

_Note_: Sessions are required for this strategy.

Install the latest version of Überauth Flickr from [https://hex.pm/packages/ueberauth_flickr](https://hex.pm/packages/ueberauth_flickr)

Documentation is available at [http://hexdocs.pm/ueberauth_flickr](http://hexdocs.pm/ueberauth_flickr)

Source code is available at [https://github.com/christopheradams/ueberauth_flickr](https://github.com/christopheradams/ueberauth_flickr)

## Installation


1. Create an application at [Flickr App Garden](https://www.flickr.com/services/apps/create/apply/).

1. Add `:ueberauth_flickr` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_flicker, "~> 0.3"}]
    end
    ```

1. Add the strategy to your applications:

    ```elixir
    def application do
      [applications: [:ueberauth_flickr]]
    end
    ```

1. Add Flickr to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        flickr: {Ueberauth.Strategy.Flickr, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.Flickr.OAuth,
      consumer_key: System.get_env("FLICKR_CONSUMER_KEY"),
      consumer_secret: System.get_env("FLICKR_CONSUMER_SECRET")
    ```

1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller

      plug Ueberauth
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initiate the request through:

    /auth/flickr

Or with options:

    /auth/flickr?perms=delete

By default the permissions are the ones defined in your application
authentication flow on Flickr. To override them, set a `perms` query value on
the request path or in your configuration. Allowed values are "read", "write",
or "delete".

```elixir
config :ueberauth, Ueberauth,
  providers: [
    flickr: {Ueberauth.Strategy.Flickr, [default_perms: "delete"]}
  ]
```

## License

Please see [LICENSE](https://github.com/christopheradams/ueberauth_flickr/blob/master/LICENSE) for licensing details.
