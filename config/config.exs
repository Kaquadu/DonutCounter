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
  redirect_uri_auth: "https://sleepy-taiga-28784.herokuapp.com/auth",
  redirect_uri_loggedin: "https://sleepy-taiga-28784.herokuapp.com/loggedin",
  verification_token: "d77fq65TdeT0hvpraviVUpnE",
  oauth_token: "xoxp-632634181587-644044063701-657074757461-015993de5a46bb0e43a5c296790fedbc",
  ttl_seconds: 1800,
  bcrypt_salt: "$2b$12$x0DHri2vRvSt.qrWyLJOVu",
  donuts_channel_id: "donuts",
  donuts_expiration_days: 30,
  donuts_checker_minutes: 15

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
