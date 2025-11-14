# Development Guide

This guide will help you set up your development environment and understand the development workflow for BlogEngine.

## Prerequisites

- **Elixir 1.14 or higher** - [Installation Guide](https://elixir-lang.org/install.html)
- **Erlang/OTP 25 or higher** - Usually installed with Elixir
- **Git** - For version control
- A text editor or IDE (VS Code with ElixirLS is recommended)

## Setting Up Your Development Environment

### 1. Clone the Repository

```bash
git clone https://github.com/codeforgood-org/elixir-blog-engine.git
cd elixir-blog-engine
```

### 2. Install Dependencies

```bash
mix deps.get
```

### 3. Verify Setup

Run tests to ensure everything is working:

```bash
mix test
```

## Development Workflow

### Running the Application

There are several ways to run the application during development:

**Method 1: Using Mix (Recommended for development)**
```bash
mix run -e "BlogEngine.CLI.start()"
```

**Method 2: Build and run escript**
```bash
mix escript.build
./blog_engine
```

**Method 3: Using IEx (Interactive Elixir)**
```bash
iex -S mix
```

Then in the IEx shell:
```elixir
BlogEngine.CLI.start()
```

### Running Tests

**Run all tests:**
```bash
mix test
```

**Run specific test file:**
```bash
mix test test/blog_engine/post_test.exs
```

**Run tests matching a pattern:**
```bash
mix test --only focus
```

**Run tests with coverage:**
```bash
mix coveralls
```

**Generate HTML coverage report:**
```bash
mix coveralls.html
open cover/excoveralls.html
```

### Code Quality

**Format code:**
```bash
mix format
```

**Check formatting without changing files:**
```bash
mix format --check-formatted
```

**Run Credo (static analysis):**
```bash
mix credo
```

**Run Credo in strict mode:**
```bash
mix credo --strict
```

**Run Dialyzer (type checking):**
```bash
# First time - create PLT files (this takes a while)
mix dialyzer --plt

# Subsequent runs
mix dialyzer
```

### Documentation

**Generate documentation:**
```bash
mix docs
```

Documentation will be available in `doc/index.html`.

**View documentation:**
```bash
open doc/index.html
```

## Project Structure Explained

```
elixir-blog-engine/
├── .github/
│   └── workflows/          # GitHub Actions CI/CD
│       ├── ci.yml          # Continuous Integration
│       └── release.yml     # Release automation
├── config/
│   ├── config.exs          # Main configuration
│   ├── dev.exs             # Development config
│   ├── test.exs            # Test config
│   └── prod.exs            # Production config
├── docs/
│   └── DEVELOPMENT.md      # This file
├── lib/
│   ├── blog_engine.ex      # Core business logic
│   └── blog_engine/
│       ├── cli.ex          # Command-line interface
│       ├── post.ex         # Post data structure
│       └── storage.ex      # JSON persistence
├── priv/
│   └── data/               # Runtime data storage
│       └── .gitkeep
├── test/
│   ├── test_helper.exs     # Test setup
│   ├── blog_engine_test.exs
│   └── blog_engine/
│       ├── post_test.exs
│       └── storage_test.exs
├── .credo.exs              # Credo configuration
├── .formatter.exs          # Code formatter config
├── .gitignore
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── mix.exs                 # Project configuration
└── README.md
```

### Key Modules

- **BlogEngine** - Core module containing business logic for CRUD operations, search, tags, etc.
- **BlogEngine.Post** - Defines the Post struct and post-related functions (creation, updating, searching)
- **BlogEngine.Storage** - Handles persistence to/from JSON files
- **BlogEngine.CLI** - Interactive command-line interface with REPL

## Debugging

### Using IEx.pry

Add `require IEx; IEx.pry()` in your code:

```elixir
def some_function(data) do
  require IEx; IEx.pry()
  # Code execution will pause here
end
```

Run with:
```bash
iex -S mix
```

### Using IO.inspect

For quick debugging:

```elixir
data
|> IO.inspect(label: "Debug")
|> some_function()
```

### Logging

Add debug output:

```elixir
require Logger
Logger.debug("Value: #{inspect(value)}")
```

## Common Tasks

### Adding a New Feature

1. Create a new branch:
   ```bash
   git checkout -b feature/my-new-feature
   ```

2. Write tests first (TDD approach):
   ```bash
   # Edit test file
   mix test
   ```

3. Implement the feature

4. Ensure all quality checks pass:
   ```bash
   mix test
   mix format
   mix credo
   ```

5. Commit and push:
   ```bash
   git add .
   git commit -m "Add feature: description"
   git push origin feature/my-new-feature
   ```

6. Open a Pull Request

### Updating Dependencies

```bash
mix deps.update --all
mix test
```

### Creating a Release

1. Update version in `mix.exs`
2. Update `CHANGELOG.md`
3. Commit changes
4. Create and push tag:
   ```bash
   git tag -a v1.1.0 -m "Release version 1.1.0"
   git push origin v1.1.0
   ```

The GitHub Actions workflow will automatically create a release with the escript binary.

## Troubleshooting

### Dependencies won't compile

```bash
mix deps.clean --all
mix deps.get
mix compile
```

### Tests are failing

```bash
# Clean build and recompile
mix clean
mix compile
mix test
```

### Dialyzer is taking too long

```bash
# Rebuild PLT from scratch
rm -rf priv/plts
mix dialyzer --plt
```

## Best Practices

1. **Write tests first** - Follow TDD principles
2. **Format your code** - Run `mix format` before committing
3. **Add documentation** - All public functions should have `@doc` and `@spec`
4. **Run quality checks** - Ensure tests and Credo pass before pushing
5. **Keep commits atomic** - One logical change per commit
6. **Write clear commit messages** - Use imperative mood

## Getting Help

- Read the [Contributing Guide](../CONTRIBUTING.md)
- Check [existing issues](https://github.com/codeforgood-org/elixir-blog-engine/issues)
- Open a new issue for bugs or questions
- Join the discussion in Pull Requests

## Resources

- [Elixir Documentation](https://hexdocs.pm/elixir/)
- [Elixir School](https://elixirschool.com/)
- [Elixir Forum](https://elixirforum.com/)
- [ExUnit Documentation](https://hexdocs.pm/ex_unit/)
- [Mix Documentation](https://hexdocs.pm/mix/)
