# Docker Guide

This guide explains how to use BlogEngine with Docker.

## Quick Start

### Using Docker

Build and run with Docker:

```bash
# Build the image
docker build -t blog-engine:latest .

# Run interactively
docker run -it --rm \
  -v $(pwd)/priv/data:/app/priv/data \
  blog-engine:latest
```

### Using Docker Compose

Even easier with docker-compose:

```bash
# Build and start
docker-compose up blog-engine

# Or run in background
docker-compose up -d blog-engine

# Attach to running container
docker attach blog-engine

# Stop
docker-compose down
```

## Image Details

### Production Image

The Dockerfile uses multi-stage builds for a minimal production image:

- **Build stage**: Uses full Elixir image to compile escript
- **Runtime stage**: Minimal Alpine image (only ~50MB)
- **Non-root user**: Runs as user `blogengine` for security
- **Single binary**: Contains entire application in escript

### Image Layers

```
alpine:3.19 (base)
├── Runtime libraries (ncurses, libstdc++)
├── blogengine user
├── blog_engine escript (~2MB)
└── priv/data directory
```

## Volume Mounting

### Persistent Data

Mount the data directory to persist posts:

```bash
docker run -it --rm \
  -v $(pwd)/priv/data:/app/priv/data \
  blog-engine:latest
```

Without volume mounting, posts will be lost when container stops.

### Backup Strategy

Your posts are automatically persisted in the mounted volume:

```bash
# Backup
cp -r priv/data backups/data-$(date +%Y%m%d)

# Restore
cp -r backups/data-20251113/* priv/data/
```

## Development with Docker

### Development Container

Use the dev service for development with hot reload:

```bash
# Start dev container
docker-compose up blog-engine-dev

# Or with make
make docker-dev
```

The dev container:
- Mounts source code as volume
- Installs dependencies in named volumes
- Runs with Mix (not escript)
- Supports interactive development

### Running Tests

```bash
# Run tests in container
docker-compose run --rm blog-engine-dev mix test

# With coverage
docker-compose run --rm blog-engine-dev mix coveralls

# Run formatter
docker-compose run --rm blog-engine-dev mix format

# Run Credo
docker-compose run --rm blog-engine-dev mix credo
```

## Advanced Usage

### Custom Data Directory

Mount a different directory for data:

```bash
docker run -it --rm \
  -v /path/to/my/blog:/app/priv/data \
  blog-engine:latest
```

### Import/Export with Docker

#### Export from Container

```bash
# Inside container, use export command
> export /app/priv/data/backup.json

# Copy from container to host
docker cp blog-engine:/app/priv/data/backup.json ./backup.json
```

#### Import to Container

```bash
# Copy from host to container
docker cp ./backup.json blog-engine:/app/priv/data/import.json

# Inside container, use import command
> import /app/priv/data/import.json
```

### Multiple Blog Instances

Run multiple isolated blog instances:

```bash
# Blog 1
docker run -it --rm \
  --name blog1 \
  -v $(pwd)/blog1-data:/app/priv/data \
  blog-engine:latest

# Blog 2 (in another terminal)
docker run -it --rm \
  --name blog2 \
  -v $(pwd)/blog2-data:/app/priv/data \
  blog-engine:latest
```

## Building Custom Images

### Build Arguments

Customize the build:

```dockerfile
# Use different Elixir version
docker build --build-arg ELIXIR_VERSION=1.15.0 -t blog-engine:custom .
```

### Multi-platform Builds

Build for multiple architectures:

```bash
# Setup buildx
docker buildx create --use

# Build for multiple platforms
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t blog-engine:latest \
  --push .
```

## Makefile Commands

Use the Makefile for convenience:

```bash
make docker-build      # Build Docker image
make docker-run        # Run in Docker
make docker-shell      # Open shell in container
```

## Security Considerations

### Non-root User

The container runs as non-root user `blogengine` (UID 1000):

```dockerfile
USER blogengine
```

### Read-only Root Filesystem

For extra security, mount root as read-only:

```bash
docker run -it --rm \
  --read-only \
  -v $(pwd)/priv/data:/app/priv/data \
  blog-engine:latest
```

### Network Isolation

BlogEngine doesn't need network access:

```bash
docker run -it --rm \
  --network none \
  -v $(pwd)/priv/data:/app/priv/data \
  blog-engine:latest
```

## Troubleshooting

### Permission Issues

If you get permission errors:

```bash
# Fix ownership
sudo chown -R 1000:1000 priv/data

# Or run with your UID
docker run -it --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd)/priv/data:/app/priv/data \
  blog-engine:latest
```

### Container Won't Start

Check logs:

```bash
docker logs blog-engine
```

### Data Not Persisting

Ensure volume is mounted correctly:

```bash
# Check mounts
docker inspect blog-engine | grep -A 10 Mounts
```

### Rebuild After Code Changes

```bash
# Force rebuild
docker-compose build --no-cache

# Or with Docker
docker build --no-cache -t blog-engine:latest .
```

## Best Practices

1. **Always mount volumes** for data persistence
2. **Use docker-compose** for easier management
3. **Tag your images** with versions
4. **Backup regularly** using export command
5. **Use dev container** for development
6. **Keep base image updated** for security patches

## Examples

### Daily Blog Routine

```bash
# Start your blog
docker-compose up -d blog-engine
docker attach blog-engine

# Work on posts...
> new
> list
> edit 1

# Exit (Ctrl+C)

# Backup
docker exec blog-engine cat /app/priv/data/posts.json > backup.json

# Stop
docker-compose down
```

### CI/CD Integration

```yaml
# .github/workflows/docker.yml
- name: Build Docker image
  run: docker build -t blog-engine:${{ github.sha }} .

- name: Test in Docker
  run: |
    docker run --rm blog-engine:${{ github.sha }} --version
```

## Resources

- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)

---

For more information, see:
- [Quick Start Guide](QUICK_START.md)
- [Development Guide](DEVELOPMENT.md)
- [Security Policy](../SECURITY.md)
