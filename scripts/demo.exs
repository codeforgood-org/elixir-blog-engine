#!/usr/bin/env elixir

# Demo script showing BlogEngine API usage
# Run with: mix run scripts/demo.exs

IO.puts("\n" <> String.duplicate("=", 80))
IO.puts("  BlogEngine API Demo")
IO.puts(String.duplicate("=", 80) <> "\n")

# Initialize the blog engine
IO.puts("Initializing BlogEngine...")
state = BlogEngine.init()
IO.puts("✓ Initialized with #{length(state.posts)} existing posts\n")

# Create some posts
IO.puts("Creating sample posts...")

{state, post1} = BlogEngine.create_post(
  state,
  "Understanding Pattern Matching",
  "Pattern matching is one of Elixir's most powerful features...",
  ["elixir", "tutorial"]
)
IO.puts("✓ Created post ##{post1.id}: #{post1.title}")

{state, post2} = BlogEngine.create_post(
  state,
  "Building Concurrent Systems",
  "Learn how to build concurrent and fault-tolerant systems with OTP...",
  ["elixir", "concurrency", "advanced"]
)
IO.puts("✓ Created post ##{post2.id}: #{post2.title}")

{state, post3} = BlogEngine.create_post(
  state,
  "My Journey with Functional Programming",
  "Switching from OOP to FP was a game-changer for me...",
  ["programming", "opinion"]
)
IO.puts("✓ Created post ##{post3.id}: #{post3.title}\n")

# List all posts
IO.puts("Listing all posts:")
IO.puts(String.duplicate("-", 80))
posts = BlogEngine.list_posts(state)
Enum.each(posts, fn post ->
  tags_str = if post.tags, do: " [#{Enum.join(post.tags, ", ")}]", else: ""
  IO.puts("[#{post.id}] #{post.title}#{tags_str}")
end)
IO.puts(String.duplicate("-", 80))
IO.puts("Total: #{length(posts)} posts\n")

# Search posts
query = "elixir"
IO.puts("Searching for '#{query}':")
results = BlogEngine.search_posts(state, query)
IO.puts("Found #{length(results)} posts matching '#{query}'")
Enum.each(results, fn post ->
  IO.puts("  - #{post.title}")
end)
IO.puts("")

# Filter by tag
tag = "tutorial"
IO.puts("Posts tagged with '#{tag}':")
tagged_posts = BlogEngine.list_posts(state, tag)
Enum.each(tagged_posts, fn post ->
  IO.puts("  - #{post.title}")
end)
IO.puts("")

# Get all tags
IO.puts("All tags with counts:")
tags = BlogEngine.get_all_tags(state)
Enum.each(tags, fn {tag, count} ->
  IO.puts("  #{tag}: #{count}")
end)
IO.puts("")

# Update a post
IO.puts("Updating post ##{post1.id}...")
{:ok, state, updated_post} = BlogEngine.update_post(
  state,
  post1.id,
  title: "Mastering Pattern Matching in Elixir"
)
IO.puts("✓ Updated: #{updated_post.title}")
IO.puts("  Created: #{BlogEngine.Post.format_date(updated_post.created_at)}")
IO.puts("  Updated: #{BlogEngine.Post.format_date(updated_post.updated_at)}\n")

# View a post
IO.puts("Viewing post ##{post2.id}:")
{:ok, post} = BlogEngine.find_post(state, post2.id)
IO.puts(String.duplicate("=", 80))
IO.puts("Title: #{post.title}")
IO.puts("Created: #{BlogEngine.Post.format_date(post.created_at)}")
IO.puts("Tags: #{Enum.join(post.tags || [], ", ")}")
IO.puts("\n#{post.body}")
IO.puts(String.duplicate("=", 80) <> "\n")

# Export posts
export_path = "/tmp/blog_demo_export.json"
IO.puts("Exporting posts to #{export_path}...")
:ok = BlogEngine.export_posts(state, export_path)
IO.puts("✓ Exported #{length(state.posts)} posts\n")

# Stats
IO.puts("Blog Statistics:")
IO.puts("  Total posts: #{length(state.posts)}")
IO.puts("  Next ID: #{state.next_id}")
IO.puts("  Unique tags: #{length(BlogEngine.get_all_tags(state))}")

total_words = Enum.reduce(state.posts, 0, fn post, acc ->
  acc + length(String.split(post.body))
end)
IO.puts("  Total words: #{total_words}")
IO.puts("  Avg words/post: #{div(total_words, length(state.posts))}\n")

# Delete a post
IO.puts("Deleting post ##{post3.id}...")
{:ok, state} = BlogEngine.delete_post(state, post3.id)
IO.puts("✓ Deleted post ##{post3.id}")
IO.puts("  Remaining posts: #{length(state.posts)}\n")

IO.puts(String.duplicate("=", 80))
IO.puts("  Demo Complete!")
IO.puts(String.duplicate("=", 80))
IO.puts("\nCheck #{export_path} to see the exported posts.")
IO.puts("Run './blog_engine' to try the interactive CLI.\n")
