# Architecture

This document describes the architecture and design decisions of BlogEngine.

## Overview

BlogEngine follows a clean, modular architecture with clear separation of concerns. The application is structured in layers:

```
┌─────────────────────────────────────┐
│         CLI Layer                   │
│    (User Interface)                 │
│    BlogEngine.CLI                   │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      Business Logic Layer           │
│    (Core Functionality)             │
│    BlogEngine                       │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      Data Layer                     │
│    BlogEngine.Post                  │
│    BlogEngine.Storage               │
└─────────────────────────────────────┘
```

## Module Responsibilities

### BlogEngine.CLI

**Purpose:** Command-line interface and user interaction

**Responsibilities:**
- Parse user commands
- Display formatted output
- Handle user input (single-line, multi-line)
- Manage the REPL (Read-Eval-Print Loop)
- Format posts for display

**Design Decisions:**
- Uses pattern matching for command parsing
- Stateful loop maintains application state
- Delegates all business logic to BlogEngine module
- No direct access to storage layer

**Key Functions:**
- `main/1` - Escript entry point
- `start/0` - Initialize and start REPL
- `loop/1` - Main REPL loop
- Command handlers (`handle_new/1`, `handle_list/2`, etc.)

### BlogEngine

**Purpose:** Core business logic and orchestration

**Responsibilities:**
- CRUD operations on posts
- Search functionality
- Tag management
- Import/Export coordination
- State management

**Design Decisions:**
- Pure functions where possible
- Returns tuples `{:ok, result}` or `{:error, reason}` for operations that can fail
- Immutable state updates
- Delegates persistence to Storage module
- No knowledge of CLI layer

**Key Functions:**
- `init/0` - Initialize application state
- `create_post/4`, `update_post/3`, `delete_post/2`
- `list_posts/2`, `find_post/2`
- `search_posts/2`
- `get_all_tags/1`
- `import_posts/2`, `export_posts/2`

**State Structure:**
```elixir
%{
  posts: [%Post{}, ...],
  next_id: integer()
}
```

### BlogEngine.Post

**Purpose:** Post data structure and post-related operations

**Responsibilities:**
- Define Post struct
- Post creation and updating
- Query matching (search, tags)
- Date formatting
- Post preview generation

**Design Decisions:**
- Enforces required keys (`@enforce_keys`)
- Uses typespec for type safety
- Immutable updates via `struct/2`
- Pure functions for all operations

**Post Structure:**
```elixir
%BlogEngine.Post{
  id: non_neg_integer(),
  title: String.t(),
  body: String.t(),
  tags: list(String.t()) | nil,
  created_at: DateTime.t(),
  updated_at: DateTime.t() | nil
}
```

### BlogEngine.Storage

**Purpose:** Persistence layer for posts

**Responsibilities:**
- Save posts to JSON file
- Load posts from JSON file
- Import/Export functionality
- Serialization/Deserialization

**Design Decisions:**
- JSON format for human-readable storage
- Pretty-printed JSON for easy inspection
- Automatic directory creation
- Graceful handling of missing files
- Preserves all post fields including timestamps

**Storage Format:**
```json
[
  {
    "id": 1,
    "title": "Post Title",
    "body": "Post body content",
    "tags": ["tag1", "tag2"],
    "created_at": "2025-11-13T17:32:15Z",
    "updated_at": null
  }
]
```

## Data Flow

### Creating a Post

```
User Input
    ↓
CLI.handle_new/1
    ↓
BlogEngine.create_post/4
    ↓
Post.new/4 (creates struct)
    ↓
Storage.save_posts/1 (persists)
    ↓
Updated State
    ↓
CLI displays confirmation
```

### Loading Posts on Startup

```
BlogEngine.init/0
    ↓
Storage.load_posts/0
    ↓
JSON file read
    ↓
Deserialize posts
    ↓
Calculate next_id
    ↓
Return initial state
```

### Searching Posts

```
User search query
    ↓
CLI.handle_search/2
    ↓
BlogEngine.search_posts/2
    ↓
Filter posts via Post.matches_query?/2
    ↓
Sort by date
    ↓
CLI displays results
```

## Design Patterns

### Separation of Concerns

Each module has a single, well-defined responsibility:
- **CLI** - User interface
- **BlogEngine** - Business logic
- **Post** - Data structure and behavior
- **Storage** - Persistence

### Immutability

All data structures are immutable. Updates create new versions:

```elixir
# Instead of mutating:
post.title = "New Title"  # Not possible in Elixir

# We create new structs:
updated_post = Post.update(post, title: "New Title")
```

### Functional Core, Imperative Shell

- **Functional Core:** Pure functions in Post and most of BlogEngine
- **Imperative Shell:** CLI handles I/O, Storage handles file operations

### Error Handling

Two approaches based on context:

**Tagged Tuples (for expected errors):**
```elixir
{:ok, post} = BlogEngine.find_post(state, id)
{:error, :not_found} = BlogEngine.find_post(state, 999)
```

**Pattern Matching:**
```elixir
case BlogEngine.find_post(state, id) do
  {:ok, post} -> display_post(post)
  {:error, :not_found} -> IO.puts("Not found")
end
```

## Persistence Strategy

### Why JSON?

- **Human-readable:** Easy to inspect and edit manually
- **Simple:** No database setup required
- **Portable:** Works on any system
- **Git-friendly:** Text format works well with version control
- **Sufficient:** Adequate for typical CLI use cases

### Storage Location

```
priv/data/posts.json
```

- `priv/` - Standard Elixir directory for runtime data
- Ignored by git (except .gitkeep)
- Automatically created if missing

### Future Considerations

The architecture is designed to easily swap storage backends:

```elixir
# Current
BlogEngine.Storage (JSON)

# Future possibilities
BlogEngine.Storage.JSON
BlogEngine.Storage.Markdown
BlogEngine.Storage.SQLite
BlogEngine.Storage.PostgreSQL
```

Simply implement the same interface:
- `load_posts/0`
- `save_posts/1`
- `import_posts/1`
- `export_posts/2`

## Testing Strategy

### Unit Tests

Each module has comprehensive unit tests:
- **Post** - Test struct creation, updates, queries
- **Storage** - Test persistence, serialization
- **BlogEngine** - Test business logic

### Integration Tests

BlogEngine tests also serve as integration tests, testing the interaction between BlogEngine, Post, and Storage modules.

### Test Isolation

- Each test starts with clean state
- Storage is cleaned up before/after tests
- No shared state between tests

## Performance Considerations

### Current Implementation

- All posts loaded into memory
- Linear search for queries
- O(n) operations for most searches

### Appropriate For

- Personal blogs (< 10,000 posts)
- CLI usage patterns
- Single-user scenarios

### Scaling Considerations

For larger datasets, consider:
- Lazy loading
- Indexing (by tag, date)
- Database backend
- Caching layer

## Security Considerations

### Input Validation

- All user input is treated as strings
- No SQL injection risk (no SQL)
- No XSS risk (CLI output only)

### File System

- Writes only to designated directory
- Validates file paths for import/export
- No shell command execution from user input

## Extension Points

### Adding New Commands

1. Add command to `@commands` list in CLI
2. Add pattern matching case in `parse_command/1`
3. Implement handler function
4. Add tests

### Adding New Post Fields

1. Update Post struct
2. Update Storage serialization/deserialization
3. Update CLI display functions
4. Add migration for existing data

### Adding New Features

The modular design makes it easy to add:
- New search algorithms
- Post categories
- Draft/published status
- Post scheduling
- RSS feed generation

## Trade-offs

### Simplicity vs. Features

**Choice:** Favor simplicity
- No database complexity
- No web server overhead
- Pure Elixir, minimal dependencies

### Performance vs. Maintainability

**Choice:** Favor maintainability
- Simple linear searches
- All data in memory
- Clear, readable code

### Flexibility vs. Constraints

**Choice:** Balance both
- Modular architecture allows changes
- Simple interface keeps it focused
- Easy to extend without breaking

## Future Architecture Considerations

### Potential Improvements

1. **Plugin System** - Allow custom commands and features
2. **Multiple Storage Backends** - Database, Markdown files, etc.
3. **Web Interface** - Optional HTTP server
4. **API Layer** - Separate business logic from CLI
5. **Event System** - Pub/sub for extensibility

### Backwards Compatibility

Design ensures:
- JSON format is stable
- API interfaces are versioned
- Migration paths for data
