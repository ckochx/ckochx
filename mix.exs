defmodule Ckochx.MixProject do
  use Mix.Project

  def project do
    [
      app: :ckochx,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Ckochx.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.15"},
      {:bandit, "~> 1.0"},
      {:earmark, "~> 1.4"},
      {:file_system, "~> 1.0", only: :dev}
    ]
  end
end
