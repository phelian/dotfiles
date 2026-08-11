---
name: bootstrap-project
description: "Scaffold a new project with the standard nix flake, direnv, justfile, tofu layering, compose and CI setup. Use when starting a new repo or when asked to bootstrap, scaffold, or set up a project skeleton."
---

# Bootstrap a project

Generates the skeleton shared by `resedagboken`, `argus`, `fp-cloud`, `financials` and
`vitaforge.ai`: nix flake + direnv devshell, a `justfile` as the only entrypoint, layered
tofu state, `ops/compose.dev.yml` for local Postgres, and a CI job that runs every step
through `nix develop --command just`.

Templates live in `templates/`. Copy them, substitute the placeholders, drop what the
answers rule out. Never invent a structure the reference repos don't use.

## 1. Resolve the target

`$ARGUMENTS` is the project name, optionally a path. Otherwise use the current directory.

Derive and state these before asking anything — don't ask for what you can read:

| Placeholder | Derived from |
| --- | --- |
| `{{PROJECT}}` | argument, else basename of cwd |
| `{{PROJECT_SNAKE}}` | `{{PROJECT}}` with `-` → `_` (HCL identifiers can't hold `-`) |
| `{{ENV_PREFIX}}` | `{{PROJECT}}` uppercased, `-` → `_` |
| `{{ORG}}` | `gh repo view --json owner` if a remote exists, else `ixdev` |
| `{{DOMAIN}}` | `{{PROJECT}}.ixdev.se` |
| `{{DB_PORT}}` | next free port — `rg --no-filename -o '127\.0\.0\.1:(54[0-9]{2})' ~/src/github.com/*/*/justfile` and take max + 1, floor 5433 |
| `{{STATE_BUCKET}}` | not derivable — leave literal, see §6 |

Per-project `{{DB_PORT}}` is deliberate: several of these databases run at once and a shared
5432 collides.

**Substitute UPPERCASE placeholders only.** `just` uses the same `{{ }}` syntax for its own
interpolation, so a `.just` fragment contains both: `{{PROJECT}}` is yours to replace,
`{{registry}}`, `{{image_tag}}`, `{{build_platform}}` and `{{args}}` are just's and must
survive into the output verbatim. Replacing them silently breaks every recipe.

## 2. Ask

One `AskUserQuestion` call, four questions. Do not ask a fifth round — infer the rest.

1. **Runtime** — Deno TS · Go · Python
2. **Frontend** — React + Vite (npm) · React + Vite (Deno workspace) · none
3. **Database** — Postgres + dbmate · Postgres + `schema.sql` + kysely-codegen · none
4. **Cloud** — fpcloud · GCP · AWS/Hetzner (tofu only) · none

Defaults when the user says "whatever you'd pick": Deno TS, React + Vite (npm), Postgres +
dbmate, fpcloud. That is `resedagboken`, the most recent setup.

## 3. Layout

Deno-workspace frontend implies the `app/` layout (`financials`, `vitaforge.ai`,
`boilerplate`); everything else uses `src/` (`resedagboken`, `argus`).

```
src/backend/    or  app/backend/     runtime code, Dockerfile, .env.example
src/frontend/   or  app/frontend/    vite + index.html
ops/                                 compose.dev.yml, runbooks, deploy scripts
tofu/                                bootstrap → database → application (+ dns)
.github/workflows/check.yml
```

## 4. Compose the flake

Start from `templates/flake.nix` and fill `{{BUILD_INPUTS}}` by unioning the rows that apply.
Keep the comments — they explain non-obvious choices and they are the reason these
devshells stay maintainable.

| Choice | Packages |
| --- | --- |
| always | `just` |
| Deno TS | `deno` |
| + npm frontend | `nodejs_22` |
| Go | `go`, `gopls`, `golangci-lint`, `gotools`, `delve` |
| Python | `python313`, `uv`, `ruff` |
| Postgres (any) | `postgresql_18`, `pgcli` |
| + dbmate | `dbmate` |
| tofu (any cloud) | `opentofu` |
| fpcloud | `fpcloudCli`, `dockerCredentialFpcloud`, `jq`, `awscli2` |
| GCP | `google-cloud-sdk`, `firebase-tools`, `awscli2` |
| AWS/Hetzner | `awscli2`, `hcloud` |

`opentofu`, never `terraform` — terraform is BUSL and would need `allowUnfree`. Only set
`config.allowUnfree = true` when something genuinely unfree is in the shell (the `fpcloud`
binary is; nothing else here is).

`{{SHELL_HOOK}}` — include only the lines that apply:

```nix
# tofu state + any AWS-backed module read credentials from the repo, not ~/.aws
export AWS_CONFIG_FILE="$PWD/.aws_config"
export AWS_SHARED_CREDENTIALS_FILE="$PWD/.aws-credentials"
export PATH="$PWD/bin:$PATH"
```

The fpcloud `dockerCredentialFpcloud` alias derivation is in `templates/flake.nix` — keep it
whenever fpcloud is selected. Docker shells out to `docker-credential-fpcloud` by that exact
name and the upstream package only installs `fpcloud`, so `just image-push` fails without it.

## 5. Compose the justfile

Concatenate `templates/justfile/base.just` with the fragments the answers select
(`deno.just`, `go.just`, `python.just`, `db-dbmate.just`, `deploy-fpcloud.just`). Rules:

- `default: @just --list` stays first
- every fragment's recipes keep their `# ---- section ----` banner
- `static-qa` and `static-fix` must exist for any runtime — CI calls them by name
- recipes needing a database depend on `compose-up`, never assume it is running
- the last comment line above a recipe becomes its `just --list` doc — end every comment
  block with a one-line summary, or the listing shows a fragment of the prose above it
- `deno.just` type-checks only `src/main.ts`, so it passes on an empty project. Once tests
  exist, widen it the way `resedagboken` does:
  `deno check src/main.ts $(find tests -name '*.test.ts' -type f)`

## 6. Tofu

Three layers, each its own state. Apply order is `bootstrap` → `database` → `application`.

`bootstrap` keeps **local** state on purpose: it creates the bucket the other layers use as
their backend, so it cannot store its own state there. Say so in a comment — it looks like a
mistake otherwise.

- **fpcloud** — copy `templates/tofu/fpcloud/`. Substitute `{{PROJECT}}`, `{{ORG}}`,
  `{{STATE_BUCKET}}`. The bucket name in a `backend "s3"` block is the bucket's
  `global_alias`, not the fpcloud display name, and it cannot be a variable — tofu forbids
  interpolation in backend config, so it is written literally and must be corrected by hand
  after `bootstrap` outputs it.
- **GCP** — read `~/src/github.com/fogpipe/boilerplate/infrastructure/` and adapt. The
  `bootstrap` layer creates the project, enables APIs, and makes the state bucket; `main`
  holds Cloud Run + Firebase Hosting + Neon. There is no template here because that config
  is large and provider-version-sensitive; lifting the current one beats reproducing it.
- **AWS/Hetzner** — `bootstrap` (S3 state bucket + DynamoDB lock) and `application` only.
- **dns** — add only if asked. It is a separate layer because it authenticates against real
  AWS SSO for Route 53 while the others use the platform's S3.

Commit `.terraform.lock.hcl`. Never commit state, `*.tfvars`, or `.aws-credentials`.

**Run `tofu fmt -recursive tofu/` after substituting.** HCL aligns `=` within a block, so a
placeholder that renders wider or narrower than the literal it replaced leaves the block
misaligned and `static-qa` fails on the first run. The templates are formatted for their
own placeholder widths, not yours.

## 7. Remaining files

| File | Source | Notes |
| --- | --- | --- |
| `.envrc` | `templates/envrc` | nix-direnv pinned by SHA; drop `dotenv_if_exists` lines for env files you don't create |
| `.gitignore` | `templates/gitignore` | drop the tofu and fpcloud blocks if unused |
| `ops/compose.dev.yml` | `templates/compose.dev.yml` | Postgres only; skip if no database |
| `.github/workflows/check.yml` | `templates/check.yml` | pin every action to a full SHA with a `# vX.Y.Z` comment |
| `CLAUDE.md` | `templates/CLAUDE.md` | fill in what the project is; leave the conventions |
| `.env.example` | — | every var the app reads, no real values |

## 8. Finish

1. Format everything you generated (`tofu fmt -recursive tofu/`, `deno fmt`, `gofmt -w .`),
   then `direnv allow` and `just static-qa` — it must pass on an empty project
2. `git init` if needed and make one commit; a nix flake ignores untracked files, so
   anything uncommitted is invisible to `nix develop`
3. Report what was skipped and what needs a real value (`{{STATE_BUCKET}}` after bootstrap,
   any `.env.example` entry)

Do not run `tofu apply`, create cloud resources, or push a remote. Scaffolding only.
