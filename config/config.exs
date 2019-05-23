# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :donuts,
  ecto_repos: [Donuts.Repo],
  client_id: "632634181587.644062506869"
  redirect_uri: "http%3A%2F%2Flocalhost%3A4000%2Floggedin"

# Configures the endpoint
config :donuts, DonutsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4KttmRn4fQSNsL8b5Yea7dUPQEmaR9OVmdtfg4UOjaafYXoALA+JCrAjEVXEosLx",
  render_errors: [view: DonutsWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Donuts.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
