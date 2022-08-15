defmodule Kuddle.Config.MixProject do
  use Mix.Project

  def project do
    [
      name: "Kuddle Config",
      app: :kuddle_config,
      description: description(),
      version: "0.3.0",
      elixir: "~> 1.10",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/IceDragon200/kuddle_config",
      homepage_url: "https://github.com/IceDragon200/kuddle_config",
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:kuddle, "~> 0.2.1"},
      {:ex_doc, "~> 0.16", only: :dev},
    ]
  end

  defp description do
    """
    Kuddle Config Provider or just general config helpers
    """
  end

  defp package do
    [
      maintainers: ["Corey Powell"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/IceDragon200/kuddle_config"
      },
    ]
  end
end
