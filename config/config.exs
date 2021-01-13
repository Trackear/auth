# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :trackear_auth,
  ecto_repos: [TrackearAuth.Repo]

# Configures the endpoint
config :trackear_auth, TrackearAuthWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jUpn2ynOD8tplfOo27oRNiK8zm3eUujIcyuzvK5UCYdQnqLFF3KRuZBOOsGhYFdq",
  render_errors: [view: TrackearAuthWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: TrackearAuth.PubSub,
  live_view: [signing_salt: "2v57IEDh"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
