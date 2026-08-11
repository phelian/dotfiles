
# ---- database ----

migrate: compose-up
    cd src/backend && deno task migrate

psql:
    pgcli "$DATABASE_URL"

# Drops the volume, so every local row goes with it.
db-reset:
    just compose-down
    docker volume rm {{PROJECT}}_{{PROJECT}}-pgdata || true
    just compose-up
    just migrate
