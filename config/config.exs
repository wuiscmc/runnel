# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :runnel,
  ecto_repos: [Runnel.Repo]

# Configures the endpoint
config :runnel, Runnel.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "UonuLrOkb9R34Fb8fy3EtN/vZsH/9HaZKhlIhlIO8b4h+fEWLy5e1iGWibiq3teB",
  render_errors: [view: Runnel.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Runnel.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
