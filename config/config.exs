# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :donuts,
  ecto_repos: [Donuts.Repo],
  client_id: "632634181587.644062506869",
  client_secret: "8ce5c827f81a18909c247b81436f72bc",
  redirect_uri_auth: "http%3A%2F%2Flocalhost%3A4000%2Fauth",
  redirect_uri_loggedin: "http%3A%2F%2Flocalhost%3A4000%2Floggedin",
  verification_token: "d77fq65TdeT0hvpraviVUpnE",
  oauth_token: "xoxp-632634181587-644044063701-642211094177-8eb7cbe17602f802f164aad6c7d5b67f",
  ttl_seconds: 1800,
  bcrypt_salt: "$2b$12$x0DHri2vRvSt.qrWyLJOVu",
  donuts_channel_id: "donuts",
  donuts_expiration_days: 30

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
