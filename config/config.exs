use Mix.Config

if Mix.env == :test do
  config :flickrex, :http_client, UeberauthFlickr.Support.MockHTTPClient

  config :ueberauth, Ueberauth,
    providers: [
      flickr: {Ueberauth.Strategy.Flickr, []}
    ]

  config :ueberauth, Ueberauth.Strategy.Flickr.OAuth,
    consumer_key: System.get_env("FLICKR_CONSUMER_KEY"),
    consumer_secret: System.get_env("FLICKR_CONSUMER_SECRET")
end

