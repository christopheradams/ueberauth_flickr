defmodule UeberauthFlickr.Mixfile do
  use Mix.Project

  @project_description """
  Flickr strategy for Überauth
  """

  @version "0.3.0"
  @source_url "https://github.com/christopheradams/ueberauth_flickr"

  def project do
    [
      app: :ueberauth_flickr,
      version: @version,
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      docs: docs(),
      description: @project_description,
      source_url: @source_url,
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ueberauth, "~> 0.6"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:flickrex, "~> 0.7 or ~> 0.8"}
    ]
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
