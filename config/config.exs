import Config

# General application configuration
config :ckochx,
  # Web server port - can be overridden at runtime
  port: 4000

# Configure logger
config :logger,
  level: :info,
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
