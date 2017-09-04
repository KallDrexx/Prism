defmodule Prism.Mixfile do
  use Mix.Project

  def project do
    [
      app: :prism,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Prism.Application, []}
    ]
  end

  defp deps do
    [
      {:ranch, "~> 1.4"}
    ]
  end
end
