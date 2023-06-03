# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :another_test, :env, Mix.env()

config :another_test,
  ecto_repos: [AnotherTest.Repo],
  generators: [binary_id: true]

config :another_test, AnotherTest.Repo,
  migration_primary_key: [name: :id, type: :binary_id]


# Configures the endpoint
config :another_test, AnotherTestWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: AnotherTestWeb.ErrorHTML, json: AnotherTestWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: AnotherTest.PubSub,
  live_view: [signing_salt: "fJQG3PI8"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :another_test, AnotherTest.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.2.7",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# This implements Ueberauth with the Github Strategy.
# There are other strategies like Twitter, Google, Apple and Facebook.
# Read more in the Ueberauth docs.
config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email"]}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")


config :another_test, Oban,
  repo: AnotherTest.Repo,
  queues: [default: 10, mailers: 20, high: 50, low: 5],
  plugins: [
    {Oban.Plugins.Pruner, max_age: (3600 * 24)},
    {Oban.Plugins.Cron,
      crontab: [
       # {"0 2 * * *", AnotherTest.Workers.DailyDigestWorker},
       # {"@reboot", AnotherTest.Workers.StripeSyncWorker},
       # {"0 2 * * *", AnotherTest.DailyReports.DailyReportWorker},
     ]}
  ]


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
