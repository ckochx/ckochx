import Config

# Development configuration
config :ckochx,
  port: 4000

# Configure logger for development
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Set a higher log level for development
config :logger,
  level: :debug
