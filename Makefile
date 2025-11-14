.PHONY: help install build run test format lint dialyzer clean docs coverage quality ci release docker

# Default target
help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

install: ## Install dependencies
	mix deps.get
	mix deps.compile

build: ## Build the escript executable
	mix escript.build
	@echo "✓ Executable built: ./blog_engine"

run: build ## Build and run the application
	./blog_engine

dev: ## Run in development mode with Mix
	mix run -e "BlogEngine.CLI.start()"

iex: ## Start IEx with the application loaded
	iex -S mix

test: ## Run all tests
	mix test

test-watch: ## Run tests in watch mode (requires mix test.watch)
	mix test.watch

format: ## Format code
	mix format

format-check: ## Check if code is formatted
	mix format --check-formatted

lint: ## Run Credo linter
	mix credo

lint-strict: ## Run Credo in strict mode
	mix credo --strict

dialyzer: ## Run Dialyzer type checker
	mix dialyzer

dialyzer-plt: ## Build Dialyzer PLT files (first time setup)
	mix dialyzer --plt

clean: ## Clean build artifacts
	mix clean
	rm -rf _build deps doc cover priv/plts blog_engine
	@echo "✓ Cleaned build artifacts"

clean-data: ## Clean data files (WARNING: deletes all posts!)
	@echo "⚠️  This will delete all posts!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		rm -rf priv/data/*.json; \
		echo "✓ Data files deleted"; \
	else \
		echo "Cancelled"; \
	fi

docs: ## Generate documentation
	mix docs
	@echo "✓ Documentation generated in doc/index.html"

coverage: ## Run tests with coverage report
	mix coveralls

coverage-html: ## Generate HTML coverage report
	mix coveralls.html
	@echo "✓ Coverage report generated in cover/excoveralls.html"

quality: format lint ## Run all code quality checks
	@echo "✓ All quality checks passed"

ci: format-check lint test dialyzer ## Run all CI checks
	@echo "✓ All CI checks passed"

deps-update: ## Update all dependencies
	mix deps.update --all
	@echo "✓ Dependencies updated"

deps-outdated: ## Check for outdated dependencies
	mix hex.outdated

release: clean install test quality build ## Prepare a release build
	@echo "✓ Release build complete"

# Docker targets
docker-build: ## Build Docker image
	docker build -t blog-engine:latest .
	@echo "✓ Docker image built: blog-engine:latest"

docker-run: ## Run in Docker container
	docker run -it --rm \
		-v $(PWD)/priv/data:/app/priv/data \
		blog-engine:latest

docker-shell: ## Open shell in Docker container
	docker run -it --rm \
		-v $(PWD)/priv/data:/app/priv/data \
		--entrypoint /bin/sh \
		blog-engine:latest

# Utility targets
check: ## Quick check (format + lint + test)
	@echo "Running quick checks..."
	@make format-check
	@make lint
	@make test
	@echo "✓ Quick checks passed"

setup: install dialyzer-plt ## Initial project setup
	@echo "✓ Project setup complete"

backup: ## Backup all posts to timestamped file
	@mkdir -p backups
	@timestamp=$$(date +%Y%m%d_%H%M%S); \
	if [ -f priv/data/posts.json ]; then \
		cp priv/data/posts.json backups/posts_$$timestamp.json; \
		echo "✓ Backup created: backups/posts_$$timestamp.json"; \
	else \
		echo "⚠️  No posts file found"; \
	fi

benchmark: ## Run performance benchmarks (if implemented)
	mix run benchmark/run.exs

all: clean install quality test build docs ## Run everything
	@echo "✓ All tasks completed"
