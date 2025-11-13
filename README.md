# BlogEngine

A powerful, feature-rich CLI blog engine built with Elixir. Manage your blog posts from the command line with an intuitive interface, persistent storage, and advanced features like tagging, search, and export/import capabilities.

## Features

- **Create, Read, Update, Delete (CRUD)** - Full post management
- **Tagging System** - Organize posts with tags
- **Search Functionality** - Find posts by keywords in title, body, or tags
- **Persistent Storage** - Posts saved to JSON automatically
- **Import/Export** - Backup and share your posts
- **Statistics** - Track your blogging activity
- **Multi-line Input** - Write longer posts comfortably
- **Timestamps** - Automatic creation and update tracking
- **Interactive CLI** - User-friendly command-line interface

## Installation

### Prerequisites

- Elixir 1.14 or higher
- Erlang/OTP 25 or higher

### Quick Start

1. Clone the repository:
```bash
git clone https://github.com/codeforgood-org/elixir-blog-engine.git
cd elixir-blog-engine
```

2. Install dependencies:
```bash
mix deps.get
```

3. Build the executable:
```bash
mix escript.build
```

4. Run the blog engine:
```bash
./blog_engine
```

Alternatively, you can run directly with Mix:
```bash
mix run -e "BlogEngine.CLI.start()"
```

## Usage

### Available Commands

| Command | Description |
|---------|-------------|
| `new` | Create a new post |
| `list` | List all posts |
| `view <id>` | View a post by ID |
| `edit <id>` | Edit a post by ID |
| `delete <id>` | Delete a post by ID |
| `search <query>` | Search posts by keyword |
| `tag <tag>` | List posts with a specific tag |
| `tags` | Show all tags and their counts |
| `export <path>` | Export all posts to a file |
| `import <path>` | Import posts from a file |
| `stats` | Show blog statistics |
| `help` | Show help message |
| `quit` | Exit the application |

### Example Workflow

```
> new
Title: Getting Started with Elixir
Body (empty line to finish):
Elixir is a dynamic, functional language designed for building
scalable and maintainable applications.

Tags (comma-separated, optional): elixir, tutorial, programming

✓ Post created successfully with ID 1

> list

=== All Posts ===
--------------------------------------------------------------------------------

[1] Getting Started with Elixir
    2025-11-13 17:32:15 | Tags: elixir, tutorial, programming

--------------------------------------------------------------------------------
Total: 1 post(s)

> search elixir

=== Search Results for 'elixir' ===
--------------------------------------------------------------------------------

[1] Getting Started with Elixir
    2025-11-13 17:32:15 | Tags: elixir, tutorial, programming

--------------------------------------------------------------------------------
Found: 1 post(s)

> stats

=== Blog Statistics ===
Total posts: 1
Total words: 12
Average words per post: 12
Total unique tags: 3
Oldest post: Getting Started with Elixir (2025-11-13 17:32:15)
Newest post: Getting Started with Elixir (2025-11-13 17:32:15)
```

## Development

### Running Tests

```bash
mix test
```

Run tests with coverage:
```bash
mix coveralls
```

Generate HTML coverage report:
```bash
mix coveralls.html
```

### Code Quality

Format code:
```bash
mix format
```

Run static analysis with Credo:
```bash
mix credo
```

Run type checking with Dialyzer:
```bash
mix dialyzer
```

### Generate Documentation

```bash
mix docs
```

Documentation will be available in `doc/index.html`.

## Project Structure

```
elixir-blog-engine/
├── lib/
│   ├── blog_engine.ex          # Core business logic
│   └── blog_engine/
│       ├── cli.ex              # Command-line interface
│       ├── post.ex             # Post struct and functions
│       └── storage.ex          # JSON persistence layer
├── test/
│   ├── blog_engine_test.exs
│   └── blog_engine/
│       ├── cli_test.exs
│       ├── post_test.exs
│       └── storage_test.exs
├── priv/
│   └── data/                   # Persistent storage directory
│       └── posts.json          # Saved posts (auto-generated)
├── config/
│   └── config.exs              # Application configuration
├── mix.exs                     # Project configuration
├── .formatter.exs              # Code formatter config
├── .credo.exs                  # Credo linter config
└── README.md
```

## Storage

Posts are automatically saved to `priv/data/posts.json` in JSON format. The file is created automatically when you create your first post.

### Backup Your Posts

Export to a backup file:
```
> export ~/my-blog-backup.json
✓ Posts exported successfully to /home/user/my-blog-backup.json
```

Import from a backup:
```
> import ~/my-blog-backup.json
✓ Posts imported successfully from /home/user/my-blog-backup.json
```

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Getting Started

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and ensure they pass
5. Format your code (`mix format`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## Architecture

BlogEngine follows a clean, modular architecture:

- **BlogEngine** - Core module with business logic (CRUD operations, search, etc.)
- **BlogEngine.Post** - Post data structure and related functions
- **BlogEngine.Storage** - Handles JSON persistence
- **BlogEngine.CLI** - Interactive command-line interface

This separation of concerns makes the codebase:
- Easy to test
- Simple to maintain
- Straightforward to extend with new features

## Roadmap

Future enhancements planned:

- [ ] Markdown support for post bodies
- [ ] Post categories
- [ ] Draft/published status
- [ ] Post scheduling
- [ ] Multiple storage backends (Markdown files, SQL)
- [ ] Web interface
- [ ] RSS feed generation
- [ ] Full-text search with ranking
- [ ] Post templates
- [ ] Bulk operations

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

Built with:
- [Elixir](https://elixir-lang.org/) - The Elixir programming language
- [Jason](https://github.com/michalmuskala/jason) - JSON encoding/decoding
- [ExUnit](https://hexdocs.pm/ex_unit/) - Testing framework
- [ExDoc](https://github.com/elixir-lang/ex_doc) - Documentation generation
- [Credo](https://github.com/rrrene/credo) - Static code analysis
- [Dialyxir](https://github.com/jeremyjh/dialyxir) - Type checking

## Support

If you encounter any issues or have questions:

1. Check the [documentation](https://hexdocs.pm/blog_engine/)
2. Search [existing issues](https://github.com/codeforgood-org/elixir-blog-engine/issues)
3. Open a [new issue](https://github.com/codeforgood-org/elixir-blog-engine/issues/new)

---

Made with ❤️ by the CodeForGood community
