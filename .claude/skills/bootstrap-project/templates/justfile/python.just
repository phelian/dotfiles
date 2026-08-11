
# ---- app ----

deps:
    uv sync

dev: compose-up deps
    uv run python -m {{PROJECT_SNAKE}}

test: deps
    uv run pytest

static-qa:
    ruff format --check .
    ruff check .

static-fix:
    ruff format .
    ruff check --fix .
