# Advanced Usage Guide

This guide covers advanced features, customizations, and power-user tips for BlogEngine.

## Table of Contents

- [Using BlogEngine as a Library](#using-blogengine-as-a-library)
- [Custom Storage Backends](#custom-storage-backends)
- [Automation and Scripting](#automation-and-scripting)
- [Performance Optimization](#performance-optimization)
- [Integration Examples](#integration-examples)
- [Extending BlogEngine](#extending-blogengine)
- [Advanced Workflows](#advanced-workflows)

## Using BlogEngine as a Library

BlogEngine can be used programmatically in other Elixir projects.

### Adding as Dependency

```elixir
# mix.exs
defp deps do
  [
    {:blog_engine, git: "https://github.com/codeforgood-org/elixir-blog-engine.git"}
  ]
end
```

### Programmatic Usage

```elixir
# Initialize
state = BlogEngine.init()

# Create posts
{state, post1} = BlogEngine.create_post(state, "Title 1", "Body 1", ["tag1"])
{state, post2} = BlogEngine.create_post(state, "Title 2", "Body 2", ["tag2"])

# Query
all_posts = BlogEngine.list_posts(state)
elixir_posts = BlogEngine.list_posts(state, "elixir")
search_results = BlogEngine.search_posts(state, "keyword")

# Update
{:ok, state, updated} = BlogEngine.update_post(state, 1, title: "New Title")

# Delete
{:ok, state} = BlogEngine.delete_post(state, 2)

# Export/Import
:ok = BlogEngine.export_posts(state, "backup.json")
{:ok, state} = BlogEngine.import_posts(state, "backup.json")
```

### GenServer Wrapper

For concurrent access, wrap in a GenServer:

```elixir
defmodule BlogEngine.Server do
  use GenServer

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def create_post(title, body, tags) do
    GenServer.call(__MODULE__, {:create_post, title, body, tags})
  end

  def list_posts(tag \\ nil) do
    GenServer.call(__MODULE__, {:list_posts, tag})
  end

  def search_posts(query) do
    GenServer.call(__MODULE__, {:search_posts, query})
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    state = BlogEngine.init()
    {:ok, state}
  end

  @impl true
  def handle_call({:create_post, title, body, tags}, _from, state) do
    {new_state, post} = BlogEngine.create_post(state, title, body, tags)
    {:reply, {:ok, post}, new_state}
  end

  @impl true
  def handle_call({:list_posts, tag}, _from, state) do
    posts = BlogEngine.list_posts(state, tag)
    {:reply, posts, state}
  end

  @impl true
  def handle_call({:search_posts, query}, _from, state) do
    posts = BlogEngine.search_posts(state, query)
    {:reply, posts, state}
  end
end

# Usage
{:ok, _pid} = BlogEngine.Server.start_link()
{:ok, post} = BlogEngine.Server.create_post("Title", "Body", ["tag"])
posts = BlogEngine.Server.list_posts()
```

## Custom Storage Backends

Implement custom storage for different backends.

### Interface

```elixir
defmodule BlogEngine.Storage.Behaviour do
  @callback load_posts() :: list(BlogEngine.Post.t())
  @callback save_posts(list(BlogEngine.Post.t())) :: :ok | {:error, term()}
  @callback export_posts(list(BlogEngine.Post.t()), String.t()) :: :ok | {:error, term()}
  @callback import_posts(String.t()) :: {:ok, list(BlogEngine.Post.t())} | {:error, term()}
end
```

### Example: Markdown Backend

```elixir
defmodule BlogEngine.Storage.Markdown do
  @behaviour BlogEngine.Storage.Behaviour

  @storage_dir "posts"

  @impl true
  def load_posts do
    File.mkdir_p(@storage_dir)

    Path.wildcard("#{@storage_dir}/*.md")
    |> Enum.map(&parse_markdown_file/1)
  end

  @impl true
  def save_posts(posts) do
    File.mkdir_p(@storage_dir)

    Enum.each(posts, fn post ->
      filename = "#{@storage_dir}/#{post.id}-#{slugify(post.title)}.md"
      content = format_post_as_markdown(post)
      File.write!(filename, content)
    end)

    :ok
  end

  defp parse_markdown_file(path) do
    content = File.read!(path)
    # Parse frontmatter and content
    # Return Post struct
  end

  defp format_post_as_markdown(post) do
    """
    ---
    id: #{post.id}
    title: #{post.title}
    tags: #{Enum.join(post.tags || [], ", ")}
    created_at: #{DateTime.to_iso8601(post.created_at)}
    ---

    #{post.body}
    """
  end

  defp slugify(string) do
    string
    |> String.downcase()
    |> String.replace(~r/[^a-z0-9]+/, "-")
    |> String.trim("-")
  end

  @impl true
  def export_posts(posts, path), do: save_posts(posts)

  @impl true
  def import_posts(path), do: {:ok, load_posts()}
end
```

### Example: PostgreSQL Backend

```elixir
defmodule BlogEngine.Storage.Postgres do
  @behaviour BlogEngine.Storage.Behaviour

  # Requires Ecto and Postgrex

  @impl true
  def load_posts do
    Repo.all(BlogPost)
    |> Enum.map(&to_post_struct/1)
  end

  @impl true
  def save_posts(posts) do
    Repo.transaction(fn ->
      Enum.each(posts, fn post ->
        changeset = BlogPost.changeset(%BlogPost{}, post_to_map(post))
        Repo.insert_or_update!(changeset)
      end)
    end)

    :ok
  end

  defp to_post_struct(blog_post) do
    %BlogEngine.Post{
      id: blog_post.id,
      title: blog_post.title,
      body: blog_post.body,
      tags: blog_post.tags,
      created_at: blog_post.created_at,
      updated_at: blog_post.updated_at
    }
  end

  defp post_to_map(post) do
    %{
      id: post.id,
      title: post.title,
      body: post.body,
      tags: post.tags,
      created_at: post.created_at,
      updated_at: post.updated_at
    }
  end

  # Implement export_posts and import_posts...
end
```

## Automation and Scripting

### Automated Post Creation

```elixir
#!/usr/bin/env elixir

# create_daily_post.exs
Mix.install([{:blog_engine, git: "..."}])

state = BlogEngine.init()
date = Date.utc_today() |> Date.to_string()

{state, post} = BlogEngine.create_post(
  state,
  "Daily Journal - #{date}",
  "Today's entry...",
  ["journal", "daily"]
)

IO.puts("Created post ##{post.id}")
```

### Batch Operations

```elixir
# Import multiple files
files = Path.wildcard("imports/*.json")

state = Enum.reduce(files, BlogEngine.init(), fn file, acc_state ->
  {:ok, new_state} = BlogEngine.import_posts(acc_state, file)
  new_state
end)
```

### Scheduled Backups

```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d)
BACKUP_DIR="$HOME/blog-backups"

mkdir -p "$BACKUP_DIR"

cd /path/to/blog-engine
./blog_engine << EOF
export $BACKUP_DIR/posts_$DATE.json
quit
EOF

echo "Backup created: $BACKUP_DIR/posts_$DATE.json"
```

Add to crontab:
```
0 2 * * * /path/to/backup.sh
```

## Performance Optimization

### Indexing Posts

```elixir
defmodule BlogEngine.Index do
  def build_indices(posts) do
    %{
      by_id: build_id_index(posts),
      by_tag: build_tag_index(posts),
      search: build_search_index(posts)
    }
  end

  defp build_id_index(posts) do
    Map.new(posts, fn post -> {post.id, post} end)
  end

  defp build_tag_index(posts) do
    posts
    |> Enum.flat_map(fn post ->
      (post.tags || [])
      |> Enum.map(fn tag -> {String.downcase(tag), post} end)
    end)
    |> Enum.group_by(&elem(&1, 0), &elem(&1, 1))
  end

  defp build_search_index(posts) do
    Map.new(posts, fn post ->
      tokens =
        [post.title, post.body]
        |> Enum.join(" ")
        |> String.downcase()
        |> String.split()
        |> MapSet.new()

      {post.id, tokens}
    end)
  end

  def search_indexed(indices, query) do
    query_tokens = query |> String.downcase() |> String.split() |> MapSet.new()

    indices.search
    |> Enum.filter(fn {_id, tokens} ->
      MapSet.intersection(tokens, query_tokens) |> MapSet.size() > 0
    end)
    |> Enum.map(fn {id, _} -> indices.by_id[id] end)
  end
end
```

### Pagination

```elixir
defmodule BlogEngine.Pagination do
  def paginate(posts, page, per_page \\ 10) do
    offset = (page - 1) * per_page

    %{
      items: Enum.slice(posts, offset, per_page),
      page: page,
      per_page: per_page,
      total: length(posts),
      total_pages: ceil(length(posts) / per_page)
    }
  end
end

# Usage
posts = BlogEngine.list_posts(state)
page1 = BlogEngine.Pagination.paginate(posts, 1, 20)
```

### Lazy Loading

```elixir
defmodule BlogEngine.Lazy do
  def list_posts_lazy(state) do
    state.posts
    |> Stream.filter(&(&1.published))
    |> Stream.map(&transform_post/1)
  end

  def search_posts_lazy(state, query) do
    state.posts
    |> Stream.filter(&Post.matches_query?(&1, query))
    |> Stream.take(100)  # Limit results
    |> Enum.to_list()
  end
end
```

## Integration Examples

### RSS Feed Generation

```elixir
defmodule BlogEngine.RSS do
  def generate_feed(posts, opts \\ []) do
    title = opts[:title] || "My Blog"
    link = opts[:link] || "https://example.com"
    description = opts[:description] || "Blog posts"

    items =
      posts
      |> Enum.take(20)
      |> Enum.map(&generate_item/1)
      |> Enum.join("\n")

    """
    <?xml version="1.0" encoding="UTF-8"?>
    <rss version="2.0">
      <channel>
        <title>#{title}</title>
        <link>#{link}</link>
        <description>#{description}</description>
        #{items}
      </channel>
    </rss>
    """
  end

  defp generate_item(post) do
    """
        <item>
          <title>#{escape_xml(post.title)}</title>
          <description>#{escape_xml(post.body)}</description>
          <pubDate>#{format_rfc822(post.created_at)}</pubDate>
        </item>
    """
  end

  defp escape_xml(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
  end

  defp format_rfc822(datetime) do
    # Format DateTime as RFC822
    Calendar.strftime(datetime, "%a, %d %b %Y %H:%M:%S +0000")
  end
end

# Usage
state = BlogEngine.init()
posts = BlogEngine.list_posts(state)
rss = BlogEngine.RSS.generate_feed(posts, title: "My Tech Blog")
File.write!("feed.xml", rss)
```

### Static Site Generation

```elixir
defmodule BlogEngine.StaticSite do
  def generate(posts, output_dir) do
    File.mkdir_p!(output_dir)

    # Generate index
    generate_index(posts, output_dir)

    # Generate individual posts
    Enum.each(posts, &generate_post(&1, output_dir))

    # Generate tag pages
    generate_tag_pages(posts, output_dir)
  end

  defp generate_index(posts, output_dir) do
    html = """
    <!DOCTYPE html>
    <html>
    <head><title>Blog</title></head>
    <body>
      <h1>Blog Posts</h1>
      #{render_post_list(posts)}
    </body>
    </html>
    """

    File.write!(Path.join(output_dir, "index.html"), html)
  end

  defp generate_post(post, output_dir) do
    html = """
    <!DOCTYPE html>
    <html>
    <head><title>#{post.title}</title></head>
    <body>
      <h1>#{post.title}</h1>
      <p>#{format_date(post.created_at)}</p>
      #{render_body(post.body)}
    </body>
    </html>
    """

    filename = "post-#{post.id}.html"
    File.write!(Path.join(output_dir, filename), html)
  end

  defp render_post_list(posts) do
    posts
    |> Enum.map(fn post ->
      "<li><a href='post-#{post.id}.html'>#{post.title}</a></li>"
    end)
    |> Enum.join("\n")
  end

  defp render_body(body) do
    body
    |> String.split("\n")
    |> Enum.map(&"<p>#{&1}</p>")
    |> Enum.join("\n")
  end

  defp format_date(datetime) do
    Calendar.strftime(datetime, "%B %d, %Y")
  end
end
```

## Extending BlogEngine

### Custom Commands

Add custom CLI commands by modifying `lib/blog_engine/cli.ex`:

```elixir
# Add to @commands list
{"archive <days>", "Archive posts older than N days"}

# Add pattern match
defp parse_command(input) do
  # ... existing patterns ...
  ["archive", days] -> {:archive, [String.to_integer(days)]}
end

# Add handler
defp handle_archive(state, days_old) do
  cutoff = DateTime.add(DateTime.utc_now(), -days_old * 86400)

  {to_archive, to_keep} =
    Enum.split_with(state.posts, fn post ->
      DateTime.compare(post.created_at, cutoff) == :lt
    end)

  archive_file = "archive_#{Date.utc_today()}.json"
  :ok = BlogEngine.Storage.export_posts(to_archive, archive_file)

  new_state = %{state | posts: to_keep}
  BlogEngine.Storage.save_posts(to_keep)

  IO.puts("✓ Archived #{length(to_archive)} posts to #{archive_file}")
  new_state
end
```

### Plugin System

Create a simple plugin system:

```elixir
defmodule BlogEngine.Plugin do
  @callback on_post_create(BlogEngine.Post.t()) :: :ok
  @callback on_post_update(BlogEngine.Post.t(), BlogEngine.Post.t()) :: :ok
  @callback on_post_delete(BlogEngine.Post.t()) :: :ok
end

defmodule BlogEngine.Plugins do
  def load_plugins do
    # Load configured plugins
    Application.get_env(:blog_engine, :plugins, [])
  end

  def trigger_event(event, data) do
    load_plugins()
    |> Enum.each(fn plugin -> apply(plugin, event, data) end)
  end
end

# Example plugin
defmodule MyPlugin do
  @behaviour BlogEngine.Plugin

  @impl true
  def on_post_create(post) do
    IO.puts("Plugin: New post created - #{post.title}")
    :ok
  end

  @impl true
  def on_post_update(old_post, new_post) do
    IO.puts("Plugin: Post updated - #{new_post.title}")
    :ok
  end

  @impl true
  def on_post_delete(post) do
    IO.puts("Plugin: Post deleted - #{post.title}")
    :ok
  end
end
```

## Advanced Workflows

### Content Pipeline

```elixir
defmodule BlogEngine.Pipeline do
  def process_post(post) do
    post
    |> validate()
    |> sanitize()
    |> add_metadata()
    |> generate_excerpt()
    |> save()
  end

  defp validate(post) do
    # Validate required fields
    post
  end

  defp sanitize(post) do
    # Remove unwanted characters
    %{post | body: String.trim(post.body)}
  end

  defp add_metadata(post) do
    # Add reading time, word count, etc.
    word_count = length(String.split(post.body))
    # Store in tags or custom field
    post
  end

  defp generate_excerpt(post) do
    # Auto-generate excerpt
    post
  end

  defp save(post) do
    # Save to storage
    post
  end
end
```

### Batch Imports

```elixir
defmodule BlogEngine.BatchImport do
  def import_from_wordpress(xml_file) do
    # Parse WordPress XML
    # Convert to BlogEngine posts
    # Import in batches
  end

  def import_from_medium(json_file) do
    # Parse Medium export
    # Convert format
    # Import posts
  end

  def import_from_markdown(directory) do
    Path.wildcard("#{directory}/**/*.md")
    |> Enum.map(&parse_markdown/1)
    |> Enum.reduce(BlogEngine.init(), fn post, state ->
      {new_state, _} = BlogEngine.create_post(
        state,
        post.title,
        post.body,
        post.tags
      )
      new_state
    end)
  end
end
```

## Best Practices

1. **Always backup before batch operations**
2. **Test custom code with small datasets first**
3. **Monitor memory usage with large datasets**
4. **Use streams for processing large collections**
5. **Index frequently queried data**
6. **Validate imported data**
7. **Log important operations**
8. **Handle errors gracefully**

---

For more information:
- [API Documentation](API.md)
- [Development Guide](DEVELOPMENT.md)
- [Architecture](ARCHITECTURE.md)
