#!/bin/bash

# Setup script for git hooks
# Run this after cloning the repository: ./scripts/setup-hooks.sh

echo "Setting up git hooks..."

# Create symlinks for hooks
ln -sf ../../.git-hooks/pre-commit .git/hooks/pre-commit
ln -sf ../../.git-hooks/commit-msg .git/hooks/commit-msg

# Make hooks executable
chmod +x .git-hooks/pre-commit
chmod +x .git-hooks/commit-msg
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg

echo "✓ Git hooks installed successfully!"
echo ""
echo "The following hooks are now active:"
echo "  - pre-commit: Runs format, credo, and tests"
echo "  - commit-msg: Validates commit message format"
echo ""
echo "To skip hooks temporarily, use: git commit --no-verify"
