# Use the official Elixir image as base
FROM elixir:1.18-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git build-base

# Set environment variables
ENV MIX_ENV=prod

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Create app directory
WORKDIR /app

# Copy mix files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get --only prod

# Copy config files
COPY config ./config

# Copy source code
COPY lib ./lib
COPY priv ./priv

# Compile the application
RUN mix compile --warnings-as-errors

# Build release
RUN mix release

# Runtime stage
FROM elixir:1.18-alpine AS runtime

# Install only the runtime dependencies we need
RUN apk add --no-cache \
    ca-certificates

# Create a non-root user
RUN addgroup -g 1000 -S ckochx && \
    adduser -u 1000 -S ckochx -G ckochx

# Create app directory
WORKDIR /app

# Copy the release from builder stage
COPY --from=builder --chown=ckochx:ckochx /app/_build/prod/rel/ckochx ./

# Copy priv directory for templates and static files
COPY --from=builder --chown=ckochx:ckochx /app/priv ./priv

# Switch to non-root user
USER ckochx

# Expose port
EXPOSE 4000

# Set environment variables
ENV HOME=/app
ENV MIX_ENV=prod
ENV PORT=4000

# Start the application
CMD ["./bin/ckochx", "start"]