# Frequently Asked Questions (FAQ)

## General Questions

### What is BlogEngine?

BlogEngine is a command-line interface (CLI) application built with Elixir for managing blog posts. It provides a simple, powerful way to create, edit, organize, and search blog posts right from your terminal.

### Who is BlogEngine for?

- Developers who prefer CLI tools
- Technical writers organizing content
- Anyone wanting a simple, local blog management system
- People learning Elixir looking for a real-world example
- Users who want full control over their blog data

### Do I need Elixir installed?

**Option 1:** Yes, if running natively, you need Elixir 1.14+ and Erlang/OTP 25+
**Option 2:** No, if using Docker - just install Docker and run the container

### Is this a web application?

No, BlogEngine is a CLI (command-line) application. It runs in your terminal and stores posts locally as JSON files. There's no web server or browser interface.

### Can I use this for an actual blog?

BlogEngine is designed for local post management and organization. To publish posts online, you would need to:
- Export posts and convert to your blog platform's format
- Use BlogEngine as a local drafting tool
- Build a custom integration with your publishing platform

## Installation & Setup

### How do I install BlogEngine?

```bash
# Clone the repository
git clone https://github.com/codeforgood-org/elixir-blog-engine.git
cd elixir-blog-engine

# Install dependencies
mix deps.get

# Build and run
mix escript.build
./blog_engine
```

Or use Docker:
```bash
docker-compose up blog-engine
```

### What are the system requirements?

**Native:**
- Elixir 1.14 or higher
- Erlang/OTP 25 or higher
- ~50MB disk space

**Docker:**
- Docker and Docker Compose
- ~100MB disk space (for image)

### The 'mix' command isn't found. What do I do?

You need to install Elixir first. Visit https://elixir-lang.org/install.html for installation instructions for your operating system.

### Can I use BlogEngine without installing Elixir?

Yes! Use the Docker version:

```bash
docker build -t blog-engine .
docker run -it --rm -v $(pwd)/priv/data:/app/priv/data blog-engine
```

## Usage Questions

### How do I create my first post?

1. Start BlogEngine: `./blog_engine`
2. Type `new` and press Enter
3. Enter title and body (press Enter twice to finish body)
4. Optionally add tags
5. Done! Your post is saved automatically

### Where are my posts stored?

Posts are stored in `priv/data/posts.json` as JSON. This file is:
- Human-readable
- Auto-created on first post
- Automatically saved after every change
- Can be backed up, edited, or moved

### How do I edit an existing post?

Use the `edit` command:
```
> edit 1
```

Then update the fields you want to change. Press Enter to keep current values.

### Can I write multi-line posts?

Yes! When entering the body:
1. Type your content across multiple lines
2. Press Enter twice (empty line) when done

### How do I delete a post?

```
> delete 1
```

You'll be asked to confirm before deletion.

### How do I search for posts?

```
> search your-keyword
```

This searches in titles, bodies, and tags (case-insensitive).

### How do tags work?

Tags help organize posts:
- Add tags when creating/editing: `elixir, tutorial, programming`
- View all tags: `tags`
- Filter by tag: `tag elixir`
- Search includes tags: `search elixir`

### Can I export my posts?

Yes! Export to JSON:
```
> export /path/to/backup.json
```

### Can I import posts from a file?

Yes! Import from JSON:
```
> import /path/to/backup.json
```

Note: Imported posts get new IDs to avoid conflicts.

### How do I backup my posts?

**Option 1:** Use export command
```
> export ~/blog-backup-$(date +%Y%m%d).json
```

**Option 2:** Copy the data file
```bash
cp priv/data/posts.json ~/backups/
```

**Option 3:** Use Makefile
```bash
make backup
```

## Technical Questions

### What format is used for storage?

JSON (JavaScript Object Notation). Posts are stored as a pretty-printed JSON array, making them:
- Human-readable
- Easy to edit manually
- Version control friendly
- Portable across systems

### Can I edit the JSON file directly?

Yes, but be careful:
- Ensure valid JSON syntax
- Maintain the required fields (id, title, body, created_at)
- Use proper ISO8601 format for dates
- Restart BlogEngine to see changes

### How much data can BlogEngine handle?

BlogEngine loads all posts into memory:
- **<1,000 posts:** Excellent performance
- **1,000-10,000 posts:** Good performance
- **>10,000 posts:** Consider a database backend

See `mix run benchmark/run.exs` for performance metrics.

### Is my data secure?

BlogEngine stores data locally as plain-text JSON:
- **Pros:** Full control, portable, readable
- **Cons:** No encryption at rest
- **Recommendation:** Use OS-level encryption or file permissions for sensitive content

### Can multiple users share a blog?

Not simultaneously. BlogEngine is designed for single-user CLI usage. For multi-user:
- Use separate data directories per user
- Implement file locking (custom)
- Consider a database backend

### Can I run BlogEngine on Windows?

Yes! Elixir works on Windows. You can:
- Install Elixir for Windows
- Use WSL (Windows Subsystem for Linux)
- Use Docker for Windows

### Does BlogEngine have a plugin system?

Not currently, but the modular architecture makes it easy to extend:
- Fork and modify the code
- Add new modules in `lib/blog_engine/`
- Contribute features via pull requests

### Can I use BlogEngine as a library?

Yes! The core modules (`BlogEngine`, `Post`, `Storage`) can be used in other Elixir projects:

```elixir
# In mix.exs
{:blog_engine, git: "https://github.com/codeforgood-org/elixir-blog-engine.git"}

# In your code
state = BlogEngine.init()
{state, post} = BlogEngine.create_post(state, "Title", "Body", nil)
```

## Development Questions

### How do I contribute?

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `mix test`
5. Run quality checks: `make quality`
6. Open a pull request

See [CONTRIBUTING.md](../CONTRIBUTING.md) for details.

### How do I run tests?

```bash
mix test              # Run all tests
mix test --trace      # Verbose output
mix coveralls         # With coverage
```

### How do I add a new command?

1. Add command to `@commands` in `lib/blog_engine/cli.ex`
2. Add pattern match in `parse_command/1`
3. Implement handler function `handle_your_command/1`
4. Add tests in `test/blog_engine/cli_test.exs`

### Where do I report bugs?

Open an issue on GitHub: https://github.com/codeforgood-org/elixir-blog-engine/issues

Use the bug report template for best results.

### How do I request features?

Open an issue with the "feature request" template: https://github.com/codeforgood-org/elixir-blog-engine/issues

## Troubleshooting

### I get "command not found: blog_engine"

Solutions:
1. Build first: `mix escript.build`
2. Use full path: `./blog_engine`
3. Or run with mix: `mix run -e "BlogEngine.CLI.start()"`

### Posts aren't saving

Check:
1. Write permissions in project directory
2. Disk space available
3. Valid JSON format (if editing manually)
4. Error messages in terminal

### I can't find my posts

Check:
- Posts file location: `priv/data/posts.json`
- Working directory when you ran BlogEngine
- Use `list` command to see all posts

### Docker container won't start

Solutions:
```bash
# Rebuild
docker-compose build --no-cache

# Check logs
docker-compose logs

# Verify permissions
sudo chown -R 1000:1000 priv/data
```

### Tests are failing

```bash
# Clean and rebuild
mix clean
mix deps.get
mix compile
mix test
```

### How do I uninstall BlogEngine?

Just delete the directory:
```bash
cd ..
rm -rf elixir-blog-engine
```

Your posts are in `elixir-blog-engine/priv/data/posts.json` - back them up first if needed!

## Advanced Questions

### Can I change the storage location?

Yes, modify `config/config.exs`:

```elixir
config :blog_engine,
  storage_dir: "/custom/path",
  storage_file: "my_posts.json"
```

### Can I use a database instead of JSON?

You can implement a new storage backend:
1. Create a new module implementing the Storage interface
2. Implement `load_posts/0`, `save_posts/1`, etc.
3. Update `BlogEngine` to use your storage module

### How do I automate backups?

**Cron job (Linux/Mac):**
```bash
# Add to crontab (crontab -e)
0 2 * * * cd /path/to/blog && make backup
```

**Task Scheduler (Windows):**
Create a scheduled task to run `make backup`

### Can I sync posts across machines?

Options:
1. Use git to version control `priv/data/posts.json`
2. Use cloud storage (Dropbox, Google Drive) for the directory
3. Export/import between machines
4. Set up a shared network drive

### How do I convert posts to Markdown?

Write a custom export script:

```elixir
posts = BlogEngine.Storage.load_posts()

Enum.each(posts, fn post ->
  File.write!(
    "#{post.id}-#{post.title}.md",
    """
    # #{post.title}

    #{post.body}

    Tags: #{Enum.join(post.tags || [], ", ")}
    """
  )
end)
```

## Still Have Questions?

- 📖 Read the [documentation](QUICK_START.md)
- 💬 Open an [issue](https://github.com/codeforgood-org/elixir-blog-engine/issues)
- 🐛 Found a bug? [Report it](https://github.com/codeforgood-org/elixir-blog-engine/issues/new?template=bug_report.md)
- 💡 Have an idea? [Request a feature](https://github.com/codeforgood-org/elixir-blog-engine/issues/new?template=feature_request.md)
