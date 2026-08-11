
# ---- app ----

deps:
    cd src/frontend && npm install

dev: compose-up deps migrate
    #!/usr/bin/env bash
    set -euo pipefail
    trap 'kill 0' EXIT
    just dev-api &
    just dev-web &
    wait

dev-api:
    cd src/backend && deno task dev

dev-web:
    cd src/frontend && npm run dev

build: deps
    cd src/frontend && npm run build

test: test-api test-web

test-api:
    cd src/backend && deno task test

test-web:
    cd src/frontend && npm run --silent test

static-qa:
    cd src/backend && deno fmt --check
    cd src/backend && deno lint
    cd src/backend && deno check src/main.ts
    cd src/frontend && npm run --silent typecheck

static-fix:
    cd src/backend && deno fmt
    cd src/backend && deno lint --fix || true
