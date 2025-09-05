import Config

# Production configuration
config :ckochx,
  # Port will be configured at runtime
  port: {:system, :integer, "PORT", 4000}

# Configure logger for production
config :logger,
  level: :info,
  compile_time_purge_matching: [
    [level_lower_than: :info]
  ]

# Reduce log noise in production
config :logger, :console,
  format: "$time [$level] $message\n",
  metadata: [:request_id]
