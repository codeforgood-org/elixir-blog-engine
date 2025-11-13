import Config

# BlogEngine configuration

# Configure the storage directory for posts
config :blog_engine,
  storage_dir: "priv/data",
  storage_file: "posts.json"

# Import environment specific config if it exists
import_config "#{config_env()}.exs"
