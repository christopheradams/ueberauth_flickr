defmodule UeberauthFlickr.Mixfile do
  use Mix.Project

  @project_description """
  Flickr strategy for Überauth
  """

  @version "0.2.1"
  @source_url "https://github.com/christopheradams/ueberauth_flickr"

  def project do
    [
      app: :ueberauth_flickr,
      version: @version,
      elixir: "~> 1.3 or ~> 1.4",
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
    [applications: [:logger, :plug, :ueberauth, :flickrex]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ueberauth, "~> 0.2"},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:flickrex, "~> 0.4"}
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
