#!/usr/bin/env elixir

# BlogEngine Performance Benchmarks
# Run with: mix run benchmark/run.exs

Mix.install([
  {:benchee, "~> 1.3"}
])

defmodule BenchmarkHelper do
  def create_sample_posts(count) do
    Enum.map(1..count, fn i ->
      %BlogEngine.Post{
        id: i,
        title: "Benchmark Post #{i}",
        body: String.duplicate("Lorem ipsum dolor sit amet. ", 100),
        tags: ["benchmark", "test", "tag#{rem(i, 5)}"],
        created_at: DateTime.utc_now(),
        updated_at: nil
      }
    end)
  end

  def create_state(post_count) do
    posts = create_sample_posts(post_count)
    %{posts: posts, next_id: post_count + 1}
  end
end

IO.puts("\n" <> String.duplicate("=", 80))
IO.puts("  BlogEngine Performance Benchmarks")
IO.puts(String.duplicate("=", 80) <> "\n")

# Benchmark: List Posts
IO.puts("Running list_posts benchmarks...")
Benchee.run(
  %{
    "list_posts (100 posts)" => fn ->
      state = BenchmarkHelper.create_state(100)
      BlogEngine.list_posts(state)
    end,
    "list_posts (1000 posts)" => fn ->
      state = BenchmarkHelper.create_state(1000)
      BlogEngine.list_posts(state)
    end,
    "list_posts (10000 posts)" => fn ->
      state = BenchmarkHelper.create_state(10000)
      BlogEngine.list_posts(state)
    end
  },
  time: 5,
  memory_time: 2,
  warmup: 2
)

IO.puts("\n")

# Benchmark: Search Posts
IO.puts("Running search_posts benchmarks...")
Benchee.run(
  %{
    "search (100 posts)" => fn ->
      state = BenchmarkHelper.create_state(100)
      BlogEngine.search_posts(state, "benchmark")
    end,
    "search (1000 posts)" => fn ->
      state = BenchmarkHelper.create_state(1000)
      BlogEngine.search_posts(state, "benchmark")
    end,
    "search (10000 posts)" => fn ->
      state = BenchmarkHelper.create_state(10000)
      BlogEngine.search_posts(state, "benchmark")
    end
  },
  time: 5,
  memory_time: 2,
  warmup: 2
)

IO.puts("\n")

# Benchmark: Filter by Tag
IO.puts("Running tag filtering benchmarks...")
Benchee.run(
  %{
    "filter by tag (100 posts)" => fn ->
      state = BenchmarkHelper.create_state(100)
      BlogEngine.list_posts(state, "benchmark")
    end,
    "filter by tag (1000 posts)" => fn ->
      state = BenchmarkHelper.create_state(1000)
      BlogEngine.list_posts(state, "benchmark")
    end,
    "filter by tag (10000 posts)" => fn ->
      state = BenchmarkHelper.create_state(10000)
      BlogEngine.list_posts(state, "benchmark")
    end
  },
  time: 5,
  memory_time: 2,
  warmup: 2
)

IO.puts("\n")

# Benchmark: Find Post
IO.puts("Running find_post benchmarks...")
Benchee.run(
  %{
    "find (100 posts, first)" => fn ->
      state = BenchmarkHelper.create_state(100)
      BlogEngine.find_post(state, 1)
    end,
    "find (100 posts, last)" => fn ->
      state = BenchmarkHelper.create_state(100)
      BlogEngine.find_post(state, 100)
    end,
    "find (1000 posts, middle)" => fn ->
      state = BenchmarkHelper.create_state(1000)
      BlogEngine.find_post(state, 500)
    end,
    "find (10000 posts, middle)" => fn ->
      state = BenchmarkHelper.create_state(10000)
      BlogEngine.find_post(state, 5000)
    end
  },
  time: 5,
  memory_time: 2,
  warmup: 2
)

IO.puts("\n")

# Benchmark: Get All Tags
IO.puts("Running get_all_tags benchmarks...")
Benchee.run(
  %{
    "get_all_tags (100 posts)" => fn ->
      state = BenchmarkHelper.create_state(100)
      BlogEngine.get_all_tags(state)
    end,
    "get_all_tags (1000 posts)" => fn ->
      state = BenchmarkHelper.create_state(1000)
      BlogEngine.get_all_tags(state)
    end,
    "get_all_tags (10000 posts)" => fn ->
      state = BenchmarkHelper.create_state(10000)
      BlogEngine.get_all_tags(state)
    end
  },
  time: 5,
  memory_time: 2,
  warmup: 2
)

IO.puts("\n" <> String.duplicate("=", 80))
IO.puts("  Benchmarks Complete!")
IO.puts(String.duplicate("=", 80))
IO.puts("\nPerformance Summary:")
IO.puts("  - list_posts: O(n log n) due to sorting")
IO.puts("  - search_posts: O(n) linear search")
IO.puts("  - filter by tag: O(n) linear filter")
IO.puts("  - find_post: O(n) linear search")
IO.puts("  - get_all_tags: O(n) with frequency counting")
IO.puts("\nRecommendations:")
IO.puts("  - For <10k posts: Current implementation is sufficient")
IO.puts("  - For >10k posts: Consider indexing or database backend")
IO.puts("")
