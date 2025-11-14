# Troubleshooting Guide

This guide helps you diagnose and fix common issues with BlogEngine.

## Quick Diagnostics

Run these commands to check your setup:

```bash
# Check Elixir installation
elixir --version

# Check if dependencies are installed
mix deps.get

# Verify compilation
mix compile

# Run tests to verify functionality
mix test
```

## Installation Issues

### Problem: "mix: command not found"

**Cause:** Elixir is not installed or not in PATH

**Solutions:**

1. Install Elixir: https://elixir-lang.org/install.html

2. Verify installation:
   ```bash
   elixir --version
   ```

3. Add to PATH (if installed but not found):
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export PATH="$PATH:/path/to/elixir/bin"
   ```

4. Alternative: Use Docker instead
   ```bash
   docker-compose up blog-engine
   ```

---

### Problem: Dependencies won't install

**Error:**
```
** (Mix) Could not fetch dependencies
```

**Solutions:**

1. Check internet connection

2. Clean and retry:
   ```bash
   mix deps.clean --all
   mix deps.get
   ```

3. Update Hex:
   ```bash
   mix local.hex --force
   mix local.rebar --force
   ```

4. Check Elixir version:
   ```bash
   elixir --version  # Should be 1.14+
   ```

---

### Problem: Compilation fails

**Error:**
```
** (CompileError) lib/blog_engine.ex:X: undefined function
```

**Solutions:**

1. Clean build:
   ```bash
   mix clean
   mix compile
   ```

2. Update dependencies:
   ```bash
   mix deps.update --all
   ```

3. Check for syntax errors:
   ```bash
   mix format --check-formatted
   ```

## Runtime Issues

### Problem: "blog_engine: command not found"

**Cause:** Escript not built or not in current directory

**Solutions:**

1. Build the escript:
   ```bash
   mix escript.build
   ```

2. Run from current directory:
   ```bash
   ./blog_engine
   ```

3. Or use Mix:
   ```bash
   mix run -e "BlogEngine.CLI.start()"
   ```

4. Or add to PATH:
   ```bash
   export PATH="$PATH:$(pwd)"
   ```

---

### Problem: Posts not saving

**Symptoms:**
- No error message
- Posts disappear after restart
- Can't find posts.json file

**Solutions:**

1. Check directory permissions:
   ```bash
   ls -la priv/data/
   # Should show write permissions
   ```

2. Create directory manually:
   ```bash
   mkdir -p priv/data
   chmod 755 priv/data
   ```

3. Check disk space:
   ```bash
   df -h .
   ```

4. Verify file location:
   ```bash
   find . -name "posts.json"
   ```

5. Check working directory:
   ```bash
   pwd  # Should be in blog-engine root
   ```

---

### Problem: Can't find posts

**Symptoms:**
- "Post not found" error
- Empty list when running `list` command
- Know posts exist but can't access them

**Solutions:**

1. Verify posts file exists:
   ```bash
   cat priv/data/posts.json
   ```

2. Check file permissions:
   ```bash
   ls -la priv/data/posts.json
   chmod 644 priv/data/posts.json
   ```

3. Validate JSON:
   ```bash
   cat priv/data/posts.json | python -m json.tool
   ```

4. Check for empty state:
   ```bash
   # List all posts
   echo "list" | ./blog_engine
   ```

---

### Problem: Corrupted JSON file

**Error:**
```
** (Jason.DecodeError) unexpected byte at position X
```

**Solutions:**

1. Backup current file:
   ```bash
   cp priv/data/posts.json priv/data/posts.json.backup
   ```

2. Validate JSON:
   ```bash
   cat priv/data/posts.json | jq .
   ```

3. Fix common issues:
   - Missing commas between objects
   - Unclosed brackets or braces
   - Invalid escape sequences in strings

4. If unfixable, start fresh:
   ```bash
   echo "[]" > priv/data/posts.json
   ```

5. Restore from backup:
   ```bash
   cp backups/posts_YYYYMMDD.json priv/data/posts.json
   ```

## Search & Filter Issues

### Problem: Search returns no results

**Symptoms:**
- Know content exists but search finds nothing
- Other commands work fine

**Solutions:**

1. Check search term:
   - Search is case-insensitive
   - Partial matches work: "eli" finds "elixir"

2. Verify data:
   ```elixir
   # In IEx
   iex -S mix
   posts = BlogEngine.Storage.load_posts()
   IO.inspect(posts)
   ```

3. Try different terms:
   - Search in title: `search title-word`
   - Search in body: `search body-content`
   - Search in tags: `search tag-name`

---

### Problem: Tag filtering not working

**Symptoms:**
- `tag <name>` returns no posts
- Know posts with that tag exist

**Solutions:**

1. Check tag name:
   - Tags are case-insensitive
   - Use exact tag name (no partial matches)

2. List all tags:
   ```
   > tags
   ```

3. Verify post tags:
   ```
   > view 1
   # Check Tags: field
   ```

## Performance Issues

### Problem: Slow performance

**Symptoms:**
- Commands take a long time
- List/search is slow
- High memory usage

**Solutions:**

1. Check number of posts:
   ```bash
   jq '. | length' priv/data/posts.json
   ```

2. Run benchmarks:
   ```bash
   mix run benchmark/run.exs
   ```

3. Optimize for large datasets:
   - Archive old posts
   - Split into multiple files
   - Use database backend (custom)

4. Check system resources:
   ```bash
   # Memory
   free -h

   # Disk I/O
   iostat
   ```

---

### Problem: Out of memory

**Error:**
```
eheap_alloc: Cannot allocate X bytes of memory
```

**Solutions:**

1. Reduce post count:
   - Export old posts
   - Archive to separate files

2. Increase VM memory:
   ```bash
   elixir --erl "+hms 512M" -S mix run -e "BlogEngine.CLI.start()"
   ```

3. Check post sizes:
   ```bash
   jq '[.[] | .body | length] | max' priv/data/posts.json
   ```

## Docker Issues

### Problem: Docker container won't start

**Error:**
```
Error response from daemon: No such image
```

**Solutions:**

1. Build the image:
   ```bash
   docker-compose build
   ```

2. Or with Docker:
   ```bash
   docker build -t blog-engine .
   ```

3. Check Docker is running:
   ```bash
   docker ps
   ```

---

### Problem: Permission denied in Docker

**Error:**
```
Permission denied: /app/priv/data/posts.json
```

**Solutions:**

1. Fix ownership:
   ```bash
   sudo chown -R 1000:1000 priv/data
   ```

2. Run with your UID:
   ```bash
   docker run -it --rm \
     --user $(id -u):$(id -g) \
     -v $(pwd)/priv/data:/app/priv/data \
     blog-engine
   ```

---

### Problem: Data not persisting in Docker

**Symptoms:**
- Posts disappear when container stops
- Changes not saved

**Solutions:**

1. Mount volume correctly:
   ```bash
   docker run -it --rm \
     -v $(pwd)/priv/data:/app/priv/data \
     blog-engine
   ```

2. Check volume mount:
   ```bash
   docker inspect blog-engine | grep Mounts -A 10
   ```

3. Use absolute paths:
   ```bash
   docker run -it --rm \
     -v /full/path/to/priv/data:/app/priv/data \
     blog-engine
   ```

## Test Issues

### Problem: Tests failing

**Error:**
```
1) test ...
   ** (MatchError) no match of right hand side value
```

**Solutions:**

1. Clean test data:
   ```bash
   rm -rf priv/data/*.json
   mix test
   ```

2. Run tests in isolation:
   ```bash
   mix test test/blog_engine/post_test.exs
   ```

3. Check for interference:
   ```bash
   # Tests should clean up after themselves
   ls priv/data/
   ```

4. Rebuild:
   ```bash
   mix clean
   mix compile
   mix test
   ```

---

### Problem: Dialyzer errors

**Error:**
```
Function ... has no local return
```

**Solutions:**

1. Rebuild PLT:
   ```bash
   rm -rf priv/plts/
   mix dialyzer --plt
   ```

2. Update dependencies:
   ```bash
   mix deps.update --all
   mix dialyzer
   ```

3. Check for type mismatches in code

## Development Issues

### Problem: Format check fails

**Error:**
```
** (Mix) mix format failed due to --check-formatted
```

**Solutions:**

1. Run formatter:
   ```bash
   mix format
   ```

2. Check specific files:
   ```bash
   mix format lib/blog_engine.ex
   ```

---

### Problem: Credo warnings

**Warnings:**
```
Warnings - potential issues
```

**Solutions:**

1. Review warnings:
   ```bash
   mix credo --strict
   ```

2. Fix automatically where possible:
   ```bash
   mix credo --strict --format=oneline
   ```

3. Add inline config if intentional:
   ```elixir
   # credo:disable-for-next-line
   ```

## Platform-Specific Issues

### macOS

**Problem:** Permission denied when running escript

**Solution:**
```bash
chmod +x blog_engine
./blog_engine
```

---

### Windows

**Problem:** Escript won't run

**Solution:**
```powershell
# Use elixir directly
elixir blog_engine
```

Or use WSL:
```bash
wsl
./blog_engine
```

---

### Linux

**Problem:** Missing dependencies

**Solution:**
```bash
# Ubuntu/Debian
sudo apt-get install erlang elixir

# Fedora
sudo dnf install erlang elixir

# Arch
sudo pacman -S elixir
```

## Getting Help

If you're still stuck:

1. **Check logs:**
   ```bash
   # Look for error messages in terminal
   ./blog_engine 2>&1 | tee blog-engine.log
   ```

2. **Gather information:**
   ```bash
   # System info
   uname -a
   elixir --version
   mix --version

   # Project info
   git rev-parse HEAD
   ls -la priv/data/
   ```

3. **Open an issue:**
   - Go to: https://github.com/codeforgood-org/elixir-blog-engine/issues
   - Use bug report template
   - Include error messages and system info

4. **Check existing issues:**
   - Search: https://github.com/codeforgood-org/elixir-blog-engine/issues?q=is%3Aissue

## Preventive Measures

### Regular Backups

```bash
# Automated backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
cp priv/data/posts.json backups/posts_$DATE.json
```

### Health Checks

```bash
# Check project health
make ci  # Runs all quality checks
```

### Keep Updated

```bash
# Update dependencies regularly
mix deps.update --all

# Check for security issues
mix deps.audit
```

---

For more help:
- [FAQ](FAQ.md)
- [Documentation](QUICK_START.md)
- [GitHub Issues](https://github.com/codeforgood-org/elixir-blog-engine/issues)
