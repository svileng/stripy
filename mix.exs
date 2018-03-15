defmodule Stripy.Mixfile do
  use Mix.Project

  @version "1.2.0"

  def project do
    [
      app: :stripy,
      version: @version,
      elixir: "~> 1.3",
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
    [{:httpoison, "~> 0.13"},
     {:poison, "~> 3.1"},
     {:ex_doc, "~> 0.14", only: :dev, runtime: false}]
  end

  defp package do
    [
      maintainers: ["Svilen Gospodinov <svilen@heresy.io>"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/heresydev/stripy"}
    ]
  end
end
