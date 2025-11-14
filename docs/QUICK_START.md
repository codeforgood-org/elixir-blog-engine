# Quick Start Guide

Get up and running with BlogEngine in under 5 minutes!

## Installation

### Option 1: From Source (Recommended)

```bash
# Clone the repository
git clone https://github.com/codeforgood-org/elixir-blog-engine.git
cd elixir-blog-engine

# Install dependencies
mix deps.get

# Build the executable
mix escript.build

# Run it!
./blog_engine
```

### Option 2: Direct Run with Mix

```bash
# Clone and enter directory
git clone https://github.com/codeforgood-org/elixir-blog-engine.git
cd elixir-blog-engine

# Install dependencies
mix deps.get

# Run directly
mix run -e "BlogEngine.CLI.start()"
```

## Your First Blog Post

Once the application starts, you'll see:

```
================================================================================
  Welcome to BlogEngine - A Powerful CLI Blog Manager
================================================================================

Type 'help' to see available commands or 'new' to create your first post.

>
```

### Create a Post

Type `new` and press Enter:

```
> new

=== Create New Post ===
Title: My First Blog Post
Body (empty line to finish):
This is my first post using BlogEngine!
It supports multiple lines.

Tags (comma-separated, optional): elixir, blogging

✓ Post created successfully with ID 1
```

### List Your Posts

```
> list

=== All Posts ===
--------------------------------------------------------------------------------

[1] My First Blog Post
    2025-11-13 17:32:15 | Tags: elixir, blogging

--------------------------------------------------------------------------------
Total: 1 post(s)
```

### View a Post

```
> view 1

================================================================================
Post #1
================================================================================
Title: My First Blog Post
Created: 2025-11-13 17:32:15
Tags: elixir, blogging

This is my first post using BlogEngine!
It supports multiple lines.
================================================================================
```

## Essential Commands

| Command | Example | Description |
|---------|---------|-------------|
| `new` | `new` | Create a new post |
| `list` | `list` | Show all posts |
| `view` | `view 1` | View post #1 |
| `edit` | `edit 1` | Edit post #1 |
| `delete` | `delete 1` | Delete post #1 |
| `search` | `search elixir` | Find posts containing "elixir" |
| `tag` | `tag tutorial` | Show posts with tag "tutorial" |
| `tags` | `tags` | List all tags |
| `stats` | `stats` | Show blog statistics |
| `help` | `help` | Show all commands |
| `quit` | `quit` | Exit the app |

## Common Tasks

### Edit a Post

```
> edit 1

=== Edit Post #1 ===
(Leave blank to keep current value)

Title [My First Blog Post]: My Updated Title
Body (empty line to finish, 'keep' to keep current):
keep
Tags [elixir, blogging] (comma-separated): elixir, blogging, updated

✓ Post updated successfully
```

### Search Posts

```
> search elixir

=== Search Results for 'elixir' ===
--------------------------------------------------------------------------------

[1] My Updated Title
    2025-11-13 17:32:15 [edited] | Tags: elixir, blogging, updated

--------------------------------------------------------------------------------
Found: 1 post(s)
```

### Filter by Tag

```
> tag blogging

=== Posts tagged with 'blogging' ===
--------------------------------------------------------------------------------

[1] My Updated Title
    2025-11-13 17:32:15 [edited] | Tags: elixir, blogging, updated

--------------------------------------------------------------------------------
Total: 1 post(s)
```

### View Statistics

```
> stats

=== Blog Statistics ===
Total posts: 1
Total words: 12
Average words per post: 12
Total unique tags: 3
Oldest post: My Updated Title (2025-11-13 17:32:15)
Newest post: My Updated Title (2025-11-13 17:32:15)
```

### Backup Your Posts

```
> export ~/my-blog-backup.json
✓ Posts exported successfully to /home/user/my-blog-backup.json
```

### Restore from Backup

```
> import ~/my-blog-backup.json
✓ Posts imported successfully from /home/user/my-blog-backup.json
```

## Tips & Tricks

### Multi-line Posts

When entering the post body, you can write multiple lines. Press Enter twice (empty line) to finish:

```
Body (empty line to finish):
This is line 1
This is line 2
This is line 3
← (press Enter on empty line to finish)
```

### Keeping Current Values When Editing

When editing, press Enter without typing to keep the current value:

```
Title [Current Title]: ← (just press Enter to keep)
```

For body, type 'keep':

```
Body (empty line to finish, 'keep' to keep current):
keep
```

### Case-Insensitive Search

Search is case-insensitive and searches in title, body, and tags:

```
> search ELIXIR    # Same as "elixir"
> search Tutorial  # Same as "tutorial"
```

### Viewing Tags

See all your tags and how many posts use each:

```
> tags

=== All Tags ===
----------------------------------------
  elixir (5)
  tutorial (3)
  advanced (2)
  blogging (1)
----------------------------------------
Total: 4 tag(s)
```

## Data Storage

Your posts are automatically saved to `priv/data/posts.json`. This file is:

- **Automatically created** on first post
- **Human-readable** JSON format
- **Auto-saved** after every change
- **Persistent** across sessions

You can view or edit this file directly if needed!

## Next Steps

1. **Create more posts** - Build your blog content
2. **Organize with tags** - Use tags to categorize posts
3. **Regular backups** - Use `export` to backup your posts
4. **Explore features** - Try all commands with `help`

## Getting Help

- Type `help` in the app for command list
- Read the [full README](../README.md) for detailed information
- Check the [Development Guide](DEVELOPMENT.md) if contributing
- Open an [issue](https://github.com/codeforgood-org/elixir-blog-engine/issues) for bugs

## Troubleshooting

### "Command not found: mix"

Install Elixir first: https://elixir-lang.org/install.html

### "Dependencies not fetched"

Run: `mix deps.get`

### "Posts not saving"

Check that you have write permissions in the project directory.

### "Can't find a post"

Use `list` to see all post IDs, then `view <id>` with the correct ID.

---

**You're all set!** Start blogging with `./blog_engine` or `mix run -e "BlogEngine.CLI.start()"`
