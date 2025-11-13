# API Documentation

This document describes the public API of BlogEngine modules.

## BlogEngine Module

The core module providing business logic for post management.

### Types

```elixir
@type post_id :: non_neg_integer()
@type posts :: list(Post.t())
@type state :: %{posts: posts(), next_id: post_id()}
```

### Functions

#### init/0

```elixir
@spec init() :: state()
```

Initializes the blog engine by loading existing posts from storage.

**Returns:** Initial state with posts and next available ID

**Example:**
```elixir
state = BlogEngine.init()
# => %{posts: [...], next_id: 5}
```

---

#### create_post/4

```elixir
@spec create_post(state(), String.t(), String.t(), list(String.t()) | nil) :: {state(), Post.t()}
```

Creates a new post with the given title, body, and optional tags.

**Parameters:**
- `state` - Current application state
- `title` - Post title
- `body` - Post body content
- `tags` - Optional list of tags (default: nil)

**Returns:** Tuple of {updated_state, created_post}

**Example:**
```elixir
{new_state, post} = BlogEngine.create_post(
  state,
  "My Title",
  "Post content here",
  ["elixir", "tutorial"]
)
```

---

#### list_posts/2

```elixir
@spec list_posts(state(), String.t() | nil) :: posts()
```

Lists all posts, optionally filtered by tag. Posts are sorted by creation date (newest first).

**Parameters:**
- `state` - Current application state
- `tag` - Optional tag to filter by (default: nil)

**Returns:** List of posts

**Example:**
```elixir
all_posts = BlogEngine.list_posts(state)
elixir_posts = BlogEngine.list_posts(state, "elixir")
```

---

#### find_post/2

```elixir
@spec find_post(state(), post_id()) :: {:ok, Post.t()} | {:error, :not_found}
```

Finds a post by its ID.

**Parameters:**
- `state` - Current application state
- `id` - Post ID to find

**Returns:**
- `{:ok, post}` if found
- `{:error, :not_found}` if not found

**Example:**
```elixir
case BlogEngine.find_post(state, 1) do
  {:ok, post} -> IO.puts(post.title)
  {:error, :not_found} -> IO.puts("Not found")
end
```

---

#### update_post/3

```elixir
@spec update_post(state(), post_id(), keyword()) :: {:ok, state(), Post.t()} | {:error, :not_found}
```

Updates a post with new attributes.

**Parameters:**
- `state` - Current application state
- `id` - Post ID to update
- `attrs` - Keyword list of attributes to update (`:title`, `:body`, `:tags`)

**Returns:**
- `{:ok, updated_state, updated_post}` if successful
- `{:error, :not_found}` if post doesn't exist

**Example:**
```elixir
{:ok, new_state, updated_post} = BlogEngine.update_post(
  state,
  1,
  title: "New Title",
  tags: ["updated"]
)
```

---

#### delete_post/2

```elixir
@spec delete_post(state(), post_id()) :: {:ok, state()} | {:error, :not_found}
```

Deletes a post by its ID.

**Parameters:**
- `state` - Current application state
- `id` - Post ID to delete

**Returns:**
- `{:ok, updated_state}` if successful
- `{:error, :not_found}` if post doesn't exist

**Example:**
```elixir
{:ok, new_state} = BlogEngine.delete_post(state, 1)
```

---

#### search_posts/2

```elixir
@spec search_posts(state(), String.t()) :: posts()
```

Searches posts by query string. Searches in title, body, and tags (case-insensitive).

**Parameters:**
- `state` - Current application state
- `query` - Search query string

**Returns:** List of matching posts (sorted by date, newest first)

**Example:**
```elixir
results = BlogEngine.search_posts(state, "elixir")
```

---

#### get_all_tags/1

```elixir
@spec get_all_tags(state()) :: list({String.t(), non_neg_integer()})
```

Gets all unique tags from all posts with their post counts.

**Parameters:**
- `state` - Current application state

**Returns:** List of {tag, count} tuples, sorted by count (descending)

**Example:**
```elixir
tags = BlogEngine.get_all_tags(state)
# => [{"elixir", 5}, {"tutorial", 3}, ...]
```

---

#### export_posts/2

```elixir
@spec export_posts(state(), String.t()) :: :ok | {:error, term()}
```

Exports all posts to a JSON file.

**Parameters:**
- `state` - Current application state
- `path` - File path to export to

**Returns:** `:ok` or `{:error, reason}`

**Example:**
```elixir
:ok = BlogEngine.export_posts(state, "/tmp/backup.json")
```

---

#### import_posts/2

```elixir
@spec import_posts(state(), String.t()) :: {:ok, state()} | {:error, term()}
```

Imports posts from a JSON file and merges with existing posts. Assigns new IDs to avoid conflicts.

**Parameters:**
- `state` - Current application state
- `path` - File path to import from

**Returns:**
- `{:ok, updated_state}` if successful
- `{:error, reason}` if file can't be read or parsed

**Example:**
```elixir
{:ok, new_state} = BlogEngine.import_posts(state, "/tmp/backup.json")
```

---

## BlogEngine.Post Module

Represents a blog post with all its metadata.

### Types

```elixir
@type t :: %__MODULE__{
  id: non_neg_integer(),
  title: String.t(),
  body: String.t(),
  tags: list(String.t()) | nil,
  created_at: DateTime.t(),
  updated_at: DateTime.t() | nil
}
```

### Functions

#### new/4

```elixir
@spec new(non_neg_integer(), String.t(), String.t(), list(String.t()) | nil) :: t()
```

Creates a new post with the given attributes.

**Parameters:**
- `id` - Post ID
- `title` - Post title
- `body` - Post body content
- `tags` - Optional list of tags (default: nil)

**Returns:** New Post struct

**Example:**
```elixir
post = Post.new(1, "Title", "Body", ["tag1"])
```

---

#### update/2

```elixir
@spec update(t(), keyword()) :: t()
```

Updates a post with new attributes. Sets the `updated_at` timestamp.

**Parameters:**
- `post` - Post to update
- `attrs` - Keyword list of attributes to update

**Returns:** Updated Post struct

**Example:**
```elixir
updated = Post.update(post, title: "New Title", tags: ["new"])
```

---

#### format_date/1

```elixir
@spec format_date(DateTime.t()) :: String.t()
```

Formats a DateTime for display.

**Parameters:**
- `datetime` - DateTime to format

**Returns:** Formatted string (YYYY-MM-DD HH:MM:SS)

**Example:**
```elixir
Post.format_date(post.created_at)
# => "2025-11-13 17:32:15"
```

---

#### preview/1

```elixir
@spec preview(t()) :: String.t()
```

Returns a short preview of the post (title and first 100 chars of body).

**Parameters:**
- `post` - Post to preview

**Returns:** Preview string

**Example:**
```elixir
preview = Post.preview(post)
```

---

#### matches_query?/2

```elixir
@spec matches_query?(t(), String.t()) :: boolean()
```

Checks if a post matches a search query (searches title, body, and tags, case-insensitive).

**Parameters:**
- `post` - Post to check
- `query` - Search query

**Returns:** true if matches, false otherwise

**Example:**
```elixir
if Post.matches_query?(post, "elixir") do
  IO.puts("Match found!")
end
```

---

#### has_tag?/2

```elixir
@spec has_tag?(t(), String.t()) :: boolean()
```

Checks if a post has a specific tag (case-insensitive).

**Parameters:**
- `post` - Post to check
- `tag` - Tag to search for

**Returns:** true if post has the tag, false otherwise

**Example:**
```elixir
if Post.has_tag?(post, "tutorial") do
  IO.puts("This is a tutorial!")
end
```

---

## BlogEngine.Storage Module

Handles persistent storage of blog posts to JSON files.

### Functions

#### load_posts/0

```elixir
@spec load_posts() :: list(Post.t())
```

Loads all posts from the storage file.

**Returns:** List of posts (empty list if file doesn't exist)

**Example:**
```elixir
posts = Storage.load_posts()
```

---

#### save_posts/1

```elixir
@spec save_posts(list(Post.t())) :: :ok | {:error, term()}
```

Saves all posts to the storage file. Creates the directory if needed.

**Parameters:**
- `posts` - List of posts to save

**Returns:** `:ok` or `{:error, reason}`

**Example:**
```elixir
:ok = Storage.save_posts(posts)
```

---

#### export_posts/2

```elixir
@spec export_posts(list(Post.t()), String.t()) :: :ok | {:error, term()}
```

Exports posts to a specified file path.

**Parameters:**
- `posts` - List of posts to export
- `path` - File path to export to

**Returns:** `:ok` or `{:error, reason}`

**Example:**
```elixir
:ok = Storage.export_posts(posts, "/tmp/export.json")
```

---

#### import_posts/1

```elixir
@spec import_posts(String.t()) :: {:ok, list(Post.t())} | {:error, term()}
```

Imports posts from a specified file path.

**Parameters:**
- `path` - File path to import from

**Returns:**
- `{:ok, posts}` if successful
- `{:error, reason}` if file can't be read or parsed

**Example:**
```elixir
{:ok, imported_posts} = Storage.import_posts("/tmp/import.json")
```

---

## BlogEngine.CLI Module

Command-line interface for the BlogEngine application.

### Functions

#### main/1

```elixir
def main(_args)
```

Main entry point for the escript.

**Parameters:**
- `_args` - Command-line arguments (currently unused)

---

#### start/0

```elixir
def start()
```

Starts the interactive blog engine CLI.

**Example:**
```elixir
BlogEngine.CLI.start()
```

---

## Usage Examples

### Basic CRUD Operations

```elixir
# Initialize
state = BlogEngine.init()

# Create
{state, post} = BlogEngine.create_post(state, "Title", "Body", ["tag"])

# Read
{:ok, post} = BlogEngine.find_post(state, post.id)

# Update
{:ok, state, post} = BlogEngine.update_post(state, post.id, title: "New Title")

# Delete
{:ok, state} = BlogEngine.delete_post(state, post.id)
```

### Search and Filter

```elixir
# Search
results = BlogEngine.search_posts(state, "elixir")

# Filter by tag
elixir_posts = BlogEngine.list_posts(state, "elixir")

# Get all tags
tags = BlogEngine.get_all_tags(state)
```

### Import/Export

```elixir
# Export
:ok = BlogEngine.export_posts(state, "backup.json")

# Import
{:ok, state} = BlogEngine.import_posts(state, "backup.json")
```

### Working with Posts

```elixir
# Create and modify
post = Post.new(1, "Title", "Body", ["tag"])
updated = Post.update(post, title: "New Title")

# Check properties
if Post.has_tag?(post, "tutorial") do
  IO.puts("This is a tutorial")
end

if Post.matches_query?(post, "elixir") do
  IO.puts("Found elixir content")
end

# Format for display
formatted_date = Post.format_date(post.created_at)
preview = Post.preview(post)
```

---

## Error Handling

All functions that can fail return tagged tuples:

```elixir
# Success
{:ok, result}
{:ok, state, result}
:ok

# Failure
{:error, reason}
{:error, :not_found}
```

Always pattern match on results:

```elixir
case BlogEngine.find_post(state, id) do
  {:ok, post} ->
    # Handle success
  {:error, :not_found} ->
    # Handle not found
end
```

---

## Thread Safety

BlogEngine is designed for single-user CLI usage and is **not thread-safe**. The state is managed through functional updates rather than shared mutable state.

If you need concurrent access, wrap operations in a GenServer or similar process.

---

For more information, see:
- [Development Guide](DEVELOPMENT.md)
- [Architecture](ARCHITECTURE.md)
- [Quick Start](QUICK_START.md)
