.PHONY: help install format lint test check clean

help:  ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-10s %s\n", $$1, $$2}'

install:  ## Create .venv, install all dependencies and the git hooks
	uv sync
	uv run pre-commit install

format:  ## Auto-fix: sort imports and apply formatting
	uv run ruff check --fix .
	uv run ruff format .

lint:  ## Check style WITHOUT changing files (this is what CI runs)
	uv run ruff check .
	uv run ruff format --check .

test:  ## Run the test suite
	uv run pytest

check: lint test  ## Everything CI will run: lint, then tests

clean:  ## Delete caches (safe: all regenerable)
	rm -rf .pytest_cache .ruff_cache
	find src tests -type d -name __pycache__ -exec rm -rf {} +
