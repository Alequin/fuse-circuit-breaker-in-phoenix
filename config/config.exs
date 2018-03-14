# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :fuse_play,
  ecto_repos: [FusePlay.Repo]

# Configures the endpoint
config :fuse_play, FusePlay.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "GiuFgeGRSQ9heraO2wmb1Lc2W4Z09n1PccgsHzzeFkI4NwAWdI3+4bG06zg07Jak",
  render_errors: [view: FusePlay.ErrorView, accepts: ~w(html json)],
  pubsub: [name: FusePlay.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
