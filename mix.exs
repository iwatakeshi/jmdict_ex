defmodule JMDictEx.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/prismify-co/jmdict_ex"

  def project do
    [
      name: "jmdict_ex",
      app: :jmdict_ex,
      version: "0.1.0",
      source_url: @source_url,
      description: description(),
      package: package(),
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.json": :test,
        "test.watch": :test
      ],
      docs: [
        main: "readme",
        source_url: @source_url,
        source_ref: "v#{@version}",
        extras: ["README.md", "LICENSE", "CHANGELOG.md"]
      ],
      coveralls: [
        exclude_modules: [Cachex],
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools, :observer],
      mod: {JMDictEx, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:briefly, "~> 0.5.1"},
      {:cachex, "~> 3.6"},
      {:poison, "~> 6.0"},
      {:httpoison, "~> 2.2"},
      {:req, "~> 0.5.1"},
      {:gitly, "~> 0.1.0"},
      {:excoveralls, "~> 0.18.1", only: :test},
      {:ex_doc, "~> 0.34.1", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A simple Elixir library for downloading and extracting JMdict files from GitHub releases.
    """
  end

  defp package do
    [
      name: "jmdict_ex",
      files: ["lib", "mix.exs", "mix.lock", "README.md", "LICENSE", "CHANGELOG.md"],
      maintainers: ["iwatakeshi"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url
      }
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
