defmodule Stripy.Mixfile do
  use Mix.Project

  @version "2.0.0"

  def project do
    [
      app: :stripy,
      version: @version,
      elixir: "~> 1.7",
      name: "Stripy",
      description: "Micro wrapper for the Stripe REST API",
      package: package(),
      docs: [
        main: "readme",
        extras: ["README.md"],
        source_url: "https://github.com/heresydev/stripy",
        source_ref: @version
      ],
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:httpoison, "~> 0.13 or ~> 1.0"},
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Svilen Gospodinov <svilen@heresy.io>"],
      licenses: ["MIT"],
      links: %{Github: "https://github.com/heresydev/stripy"}
    ]
  end
end
