defmodule UeberauthFlickr.Mixfile do
  use Mix.Project

  @project_description """
  Flickr strategy for Überauth
  """

  @version "0.1.0"
  @source_url "https://github.com/christopheradams/ueberauth_flickr"

  def project do
    [app: :ueberauth_flickr,
     version: "0.1.0",
     elixir: "~> 1.3 or ~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     docs: docs(),
     description: @project_description,
     source_url: @source_url,
     package: package(),
     deps: deps()]
  end

  def application do
    [applications: [:logger, :plug, :ueberauth, :flickrex]]
  end

  defp deps do
    [{:ueberauth, "~> 0.2"},
     {:ex_doc, ">= 0.0.0", only: :dev},
     {:flickrex, "~> 0.3"}]
  end

  defp docs() do
    [
      source_ref: "v#{@version}",
      main: "readme",
      extras: [
        "README.md": [title: "README"]
      ]
    ]
  end

  defp package do
    [
     name: :ueberauth_flickr,
     maintainers: ["Christopher Adams"],
     licenses: ["MIT"],
     links: %{
       "GitHub" => @source_url
     }
    ]
  end
end
