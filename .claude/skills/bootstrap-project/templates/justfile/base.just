set dotenv-load := true
set dotenv-filename := "src/backend/.env.local"

export DATABASE_URL := env_var_or_default("DATABASE_URL", "postgres://{{PROJECT}}:{{PROJECT}}@127.0.0.1:{{DB_PORT}}/{{PROJECT}}_dev?sslmode=disable")
export {{ENV_PREFIX}}_DOMAIN := env_var_or_default("{{ENV_PREFIX}}_DOMAIN", "{{DOMAIN}}")

# Container image is ${{{ENV_PREFIX}}_REGISTRY}/web. Image tag defaults to the short git sha;
# build platform defaults to amd64 (flip {{ENV_PREFIX}}_BUILD_PLATFORM if the nodes are ARM).
registry := env_var_or_default("{{ENV_PREFIX}}_REGISTRY", "registry.cloud.fogpipe.com/{{ORG}}/{{PROJECT}}")
image_tag := env_var_or_default("{{ENV_PREFIX}}_IMAGE_TAG", `git rev-parse --short HEAD`)
build_platform := env_var_or_default("{{ENV_PREFIX}}_BUILD_PLATFORM", "linux/amd64")

default:
    @just --list

compose-up:
    docker compose --file ops/compose.dev.yml up --detach --wait

compose-down:
    docker compose --file ops/compose.dev.yml down
