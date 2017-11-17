# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :firestorm,
  ecto_repos: [Firestorm.Repo]

# Configures the endpoint
config :firestorm, FirestormWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "cxR15LVDp04mh3ZoV0GuJ9mB26TM3KcYbJ/OnysFJD9KfYmeNqr+Re3geFPrgocA",
  render_errors: [view: FirestormWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Firestorm.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :ueberauth, Ueberauth,
  providers: [
    # We don't need any permissions on GitHub as we're just using it as an
    # identity provider, so we'll set an empty default scope.
    github: {Ueberauth.Strategy.Github, [default_scope: ""]}
  ]

# We also need a github client id and secret. I've already generated an
# application on github and I've stored these secrets somewhere...secret.
config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :scrivener_html,
  routes_helper: FirestormWeb.Router.Helpers,
  # We'll start with the bootstrap view_style, but eventually we'll define our
  # own.
  view_style: :bootstrap

# I already have an environment variable with my API Key
config :firestorm, FirestormWeb.Mailer,
  adapter: Bamboo.SendGridAdapter,
  api_key: System.get_env("SENDGRID_API_KEY")

config :firestorm, :aws,
  access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  bucket: System.get_env("AWS_S3_BUCKET"),
  region: System.get_env("AWS_S3_REGION")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"