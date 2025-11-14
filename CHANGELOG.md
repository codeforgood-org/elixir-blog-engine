# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Complete project restructure with proper Mix project layout
- Modular architecture with separate concerns (Post, Storage, CLI, Core)
- Persistent JSON storage for posts
- Edit functionality for existing posts
- Search functionality across title, body, and tags
- Tag-based organization and filtering
- Statistics command showing blog metrics
- Import/Export functionality for backup and migration
- Comprehensive documentation with examples
- Full test suite with ExUnit
- Code quality tools (Credo, Dialyzer)
- CI/CD pipeline with GitHub Actions
- Escript build support for standalone executable
- Multi-line input support for post bodies
- Automatic timestamps for creation and updates
- Enhanced CLI with better formatting and user feedback

### Changed
- Converted from single-file script to full Mix project
- Improved error handling throughout
- Enhanced user interface with better visual separation
- Better date formatting for readability

### Removed
- Single-file blog_engine.exs implementation (replaced by modular structure)

## [1.0.0] - 2025-11-13

### Added
- Initial release with basic CRUD functionality
- Simple CLI interface
- In-memory post storage
- List, view, create, and delete commands

---

[Unreleased]: https://github.com/codeforgood-org/elixir-blog-engine/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/codeforgood-org/elixir-blog-engine/releases/tag/v1.0.0
