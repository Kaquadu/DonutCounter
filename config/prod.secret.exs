use Mix.Config

# In this file, we keep production configuration that
# you'll likely want to automate and keep away from
# your version control system.
#
# You should document the content of this
# file or create a script for recreating it, since it's
# kept out of version control and might be hard to recover
# or recreate for your teammates (or yourself later on).
config :donuts, DonutsWeb.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configure your database
config :donuts, Donuts.Repo,
  ssl: true,
  username: System.get_env("DATABASE_USERNAME"),
  password: System.get_env("DATABASE_PASSWORD"),
  database: "donuts_prod",
  size: 20
  #pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
  # adapter: Ecto.Adapters.Postgres,
  # username: "postgres",
  # password: "postgres",
  # database: "donuts_prod",
  # pool_size: 15
