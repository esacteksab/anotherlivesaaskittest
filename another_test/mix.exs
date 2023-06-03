defmodule AnotherTest.MixProject do
  use Mix.Project

  def project do
    [
      app: :another_test,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {AnotherTest.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # ADDITIONAL PACKAGES
      {:absinthe, "~> 1.7.1"},
      {:absinthe_plug, "~> 1.5.8"},
      {:cachex, "~> 3.6.0"},
      {:eqrcode, "~> 0.1.10"},
      {:nimble_totp, "~> 1.0.0"},
      {:wallaby, "~> 0.30.3", runtime: false, only: :test},
      {:waffle, "~> 1.1.7"},
      {:waffle_ecto, "~> 0.0.12"},

      # If using S3:
      {:ex_aws, "~> 2.4.2"},
      {:ex_aws_s3, "~> 2.4.0"},
      {:hackney, "~> 1.18.1"},
      {:sweet_xml, "~> 0.7.3"},
      {:fun_with_flags, "~> 1.10.1"},
      {:fun_with_flags_ui, "~> 0.8.1"},
      {:stripity_stripe, "~> 2.17.3"},
      {:flop, "~> 0.20.1"},
      {:flop_phoenix, "~> 0.19.0"},
      {:guardian, "~> 2.3.1"},
      {:ueberauth, "~> 0.10.5"},
      {:ueberauth_github, "~> 0.8.3"},
      {:premailex, "~> 0.3.18"},
      {:oban, "~> 2.15.1"},
      {:bcrypt_elixir, "~> 3.0"},
      {:credo, "~> 1.7.0", only: [:dev, :test], runtime: false},
      {:sobelow, "~> 0.12.2", only: [:dev, :test], runtime: false},

      # DEFAULT PACKAGES
      {:phoenix, "~> 1.7.2"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.18.16"},
      {:floki, ">= 0.30.0"},
      {:phoenix_live_dashboard, "~> 0.7.2"},
      {:esbuild, "~> 0.7", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2.0", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.3"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.5"},
      {:saas_kit, "1.0.0", only: :dev},
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
