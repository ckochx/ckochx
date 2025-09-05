import Config

# Runtime configuration for releases

# Configure the web server port from environment variable
if port = System.get_env("PORT") do
  config :ckochx, port: String.to_integer(port)
end

# Configure host for deployment
if host = System.get_env("HOST") do
  config :ckochx, host: host
end

# Hot upgrade configuration
config :ckochx,
  # Enable hot code upgrades
  enable_hot_upgrades: true,
  # Upgrade check interval (in milliseconds)
  upgrade_check_interval: 30_000

# Configure release-specific settings
config :logger,
  level: String.to_existing_atom(System.get_env("LOG_LEVEL") || "info")

# Ensure required environment variables are present
required_env_vars = ["PORT"]
missing_vars = Enum.filter(required_env_vars, &is_nil(System.get_env(&1)))

if missing_vars != [] do
  raise """
  Missing required environment variables: #{Enum.join(missing_vars, ", ")}

  Please set these environment variables before starting the application.
  """
end
