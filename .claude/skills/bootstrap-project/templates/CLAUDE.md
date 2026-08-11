# {{PROJECT}}

<!-- One paragraph: what this is and who uses it. -->

## Layout

| Path | What |
| --- | --- |
| `src/backend/` | API + migrations |
| `src/frontend/` | Vite SPA |
| `ops/` | compose, runbooks, deploy scripts |
| `tofu/` | infrastructure, one state layer per directory |

## Working here

`just` is the entrypoint — read the `justfile` before reaching for a raw command, and add a
recipe rather than documenting a command someone has to retype.

- `just dev` — database, migrations, API and web
- `just static-qa` — what CI runs; must pass before a commit
- `just test`

The devshell is the flake. If a tool is missing, add it to `flake.nix` rather than installing
it globally, or CI will not have it — every CI step runs `nix develop --command just <recipe>`.

## Database

Postgres in `ops/compose.dev.yml` on port {{DB_PORT}} (non-default so several projects can run
at once). Migrations are dbmate SQL under `src/backend/db/migrations/` and are the source of
truth; `schema.sql` is a generated dump and is gitignored. Never edit an applied migration —
add a new one.

## Infrastructure

`tofu`, never `terraform`. Three layers, applied in order:

1. `tofu/bootstrap` — project + state bucket. **Local state**, because it creates the bucket
   the other layers use as their backend.
2. `tofu/database` — managed Postgres.
3. `tofu/application` — the app, pinned to an image tag.

Commit `.terraform.lock.hcl`. Never commit state, `*.tfvars`, or `.aws-credentials`.
