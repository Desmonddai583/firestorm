defmodule FirestormData.Mixfile do
  use Mix.Project

  def project do
    [
      app: :firestorm_data,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {FirestormData.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 2.1.4"},
      {:postgrex, "~> 0.11"}
    ]
  end
end
