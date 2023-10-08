defmodule RedixPool.MixProject do
  use Mix.Project

  @description "A name-based pool implement built on Redix."
  @github_url "https://github.com/enjolras1205/redix_pool"
  @version "0.1.0"

  def project do
    [
      app: :redix_pool,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      test_coverage: [ignore_modules: [RedixPool.Helper]],
      elixirc_paths: elixirc_paths(Mix.env()),
      package: [
        name: :redix_conn_pool,
        licenses: ["MIT"],
        links: %{
          "GitHub" => @github_url
        },
        description: @description
      ],
      docs: [
        main: "RedixPool",
        source_ref: "v#{@version}",
        source_url: @github_url,
        extras: [
          "README.md",
          "LICENSE": [title: "License"]
        ]
      ],
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:redix, "~> 1.2"},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
