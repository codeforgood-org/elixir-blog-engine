# Build stage
FROM hexpm/elixir:1.16.0-erlang-26.2.1-alpine-3.19.0 AS build

# Install build dependencies
RUN apk add --no-cache build-base git

# Set working directory
WORKDIR /app

# Install hex and rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./

# Install dependencies
RUN mix deps.get --only prod && \
    mix deps.compile

# Copy application code
COPY lib ./lib
COPY config ./config
COPY priv ./priv

# Build escript
ENV MIX_ENV=prod
RUN mix escript.build

# Runtime stage
FROM alpine:3.23

# Install runtime dependencies
RUN apk add --no-cache \
    ncurses-libs \
    libstdc++ \
    libgcc

# Create non-root user
RUN addgroup -g 1000 blogengine && \
    adduser -D -u 1000 -G blogengine blogengine

# Set working directory
WORKDIR /app

# Copy escript from build stage
COPY --from=build --chown=blogengine:blogengine /app/blog_engine /app/blog_engine

# Create data directory
RUN mkdir -p /app/priv/data && \
    chown -R blogengine:blogengine /app

# Switch to non-root user
USER blogengine

# Set entrypoint
ENTRYPOINT ["/app/blog_engine"]

# Labels
LABEL maintainer="codeforgood-org" \
      description="BlogEngine - A powerful CLI blog manager built with Elixir" \
      version="1.0.0"
