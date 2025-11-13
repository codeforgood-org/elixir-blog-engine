import Config

# Test-specific configuration

# Use a separate directory for test data to avoid interfering with dev data
config :blog_engine,
  storage_dir: "test/fixtures/data",
  storage_file: "test_posts.json"
