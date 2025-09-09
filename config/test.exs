import Config

# Configure logger for test environment
config :logger, level: :warning

# Configure test environment specific settings
config :ckochx,
  port: 4001
