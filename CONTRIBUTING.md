# Contributing to BlogEngine

Thank you for your interest in contributing to BlogEngine! This document provides guidelines and instructions for contributing.

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- A clear, descriptive title
- Exact steps to reproduce the problem
- Expected behavior vs actual behavior
- Your environment (Elixir version, OS, etc.)
- Any relevant logs or error messages

### Suggesting Enhancements

Enhancement suggestions are welcome! Please provide:

- A clear, descriptive title
- Detailed description of the proposed functionality
- Why this enhancement would be useful
- Any implementation ideas you might have

### Pull Requests

1. Fork the repository
2. Create a new branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. Make your changes following our coding standards (see below)

4. Add or update tests as necessary

5. Ensure all tests pass:
   ```bash
   mix test
   ```

6. Format your code:
   ```bash
   mix format
   ```

7. Run static analysis:
   ```bash
   mix credo
   ```

8. Commit your changes with a clear commit message:
   ```bash
   git commit -m "Add feature: brief description"
   ```

9. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

10. Open a Pull Request with a clear title and description

## Development Setup

### Prerequisites

- Elixir 1.14+
- Erlang/OTP 25+
- Git

### Setup Steps

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/elixir-blog-engine.git
cd elixir-blog-engine

# Add upstream remote
git remote add upstream https://github.com/codeforgood-org/elixir-blog-engine.git

# Install dependencies
mix deps.get

# Run tests
mix test

# Build the executable
mix escript.build
```

## Coding Standards

### Elixir Style Guide

- Follow the [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide)
- Use `mix format` to automatically format code
- Run `mix credo` to check for code quality issues
- Maximum line length: 120 characters (enforced by formatter)

### Documentation

- Add `@moduledoc` to all modules
- Add `@doc` to all public functions
- Include `@spec` type specifications for public functions
- Provide usage examples in documentation when helpful

Example:
```elixir
@doc """
Creates a new post with the given attributes.

## Examples

    iex> BlogEngine.Post.new(1, "Hello", "World", ["elixir"])
    %BlogEngine.Post{id: 1, title: "Hello", ...}
"""
@spec new(non_neg_integer(), String.t(), String.t(), list(String.t()) | nil) :: t()
def new(id, title, body, tags \\ nil) do
  # implementation
end
```

### Testing

- Write tests for all new functionality
- Maintain or improve code coverage
- Use descriptive test names
- Group related tests with `describe` blocks

Example:
```elixir
defmodule BlogEngine.PostTest do
  use ExUnit.Case
  alias BlogEngine.Post

  describe "new/4" do
    test "creates a post with all fields" do
      post = Post.new(1, "Title", "Body", ["tag"])
      assert post.id == 1
      assert post.title == "Title"
    end
  end
end
```

### Commits

- Use clear, descriptive commit messages
- Start with a verb in the imperative mood ("Add", "Fix", "Update")
- Keep the first line under 72 characters
- Add detailed description if needed in the commit body

Good examples:
```
Add search functionality for posts
Fix date formatting in post display
Update README with installation instructions
```

## Project Structure

Understanding the project structure will help you contribute effectively:

```
lib/
├── blog_engine.ex          # Core business logic
└── blog_engine/
    ├── cli.ex              # User interface
    ├── post.ex             # Data structure
    └── storage.ex          # Persistence

test/
├── blog_engine_test.exs
└── blog_engine/
    ├── cli_test.exs
    ├── post_test.exs
    └── storage_test.exs
```

## Testing

### Running Tests

```bash
# Run all tests
mix test

# Run specific test file
mix test test/blog_engine/post_test.exs

# Run tests matching a pattern
mix test --only tag_name

# Run with coverage
mix coveralls
```

### Writing Tests

- Test both happy paths and error cases
- Use factories or fixtures for test data
- Clean up any test artifacts (files, etc.)
- Mock external dependencies when appropriate

## Pull Request Process

1. **Update Documentation** - Ensure README and module docs reflect your changes

2. **Update CHANGELOG.md** - Add an entry under "Unreleased" section

3. **Pass All Checks** - Ensure tests, formatting, and Credo pass

4. **Request Review** - Tag maintainers for review

5. **Address Feedback** - Make requested changes promptly

6. **Keep Updated** - Rebase on main if needed:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

## Review Process

Maintainers will review your PR for:

- Code quality and style
- Test coverage
- Documentation completeness
- Backward compatibility
- Performance implications

We aim to review PRs within 3-5 business days.

## Recognition

Contributors will be recognized in:
- CHANGELOG.md for their contributions
- GitHub contributors page

## Questions?

Feel free to:
- Open an issue for discussion
- Reach out to maintainers
- Ask questions in your PR

Thank you for contributing to BlogEngine!
