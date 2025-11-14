#!/bin/bash

# Script to import example posts
# Usage: ./scripts/import_examples.sh

set -e

echo "BlogEngine - Import Example Posts"
echo "=================================="
echo ""

EXAMPLE_FILE="examples/sample_posts.json"
DATA_DIR="priv/data"
DATA_FILE="$DATA_DIR/posts.json"

# Check if example file exists
if [ ! -f "$EXAMPLE_FILE" ]; then
    echo "❌ Error: Example file not found: $EXAMPLE_FILE"
    exit 1
fi

# Check if data directory exists, create if not
if [ ! -d "$DATA_DIR" ]; then
    echo "Creating data directory: $DATA_DIR"
    mkdir -p "$DATA_DIR"
fi

# Backup existing posts if any
if [ -f "$DATA_FILE" ]; then
    BACKUP_FILE="${DATA_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    echo "⚠️  Existing posts found. Creating backup: $BACKUP_FILE"
    cp "$DATA_FILE" "$BACKUP_FILE"
fi

# Copy example posts
echo "Copying example posts..."
cp "$EXAMPLE_FILE" "$DATA_FILE"

echo ""
echo "✓ Example posts imported successfully!"
echo ""
echo "You can now run './blog_engine' and use 'list' to see the posts."
echo ""
echo "Example commands to try:"
echo "  list              - View all posts"
echo "  view 1            - View the welcome post"
echo "  search elixir     - Search for Elixir posts"
echo "  tag tutorial      - View tutorial posts"
echo "  tags              - See all tags"
echo ""
