terraform {
  required_version = ">= 1.6"

  required_providers {
    fpcloud = {
      source  = "fogpipe/fpcloud"
      version = "~> 0.10"
    }
  }

  # State in the fpcloud bucket created by tofu/bootstrap (see tofu/database for the profile
  # mechanism). Apply tofu/database BEFORE this module — the platform injects DATABASE_URL only
  # if the db already exists in the project (there is no cross-state resource dependency).
  backend "s3" {
    bucket    = "{{STATE_BUCKET}}"
    key       = "application/terraform.tfstate"
    region    = "garage"
    endpoints = { s3 = "https://s3.cloud.fogpipe.com" }
    profile   = "{{PROJECT}}-state"

    use_path_style              = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
  }
}

provider "fpcloud" {}

# Project + database are owned by other modules; reference the project by name.
data "fpcloud_project" "{{PROJECT_SNAKE}}" {
  name = var.project
}

# One container serves the JSON API and the built SPA — no separate static host, no CORS.
resource "fpcloud_app" "web" {
  project_id = data.fpcloud_project.{{PROJECT_SNAKE}}.id
  name       = "web"
  image      = "${var.registry}/web:${var.image_tag}"

  # A vanity slug replaces the whole derived label, so there is no second hostname to attach a
  # custom domain to. Globally unique, first come first served.
  url_slug = var.slug
  port     = 8000
  ingress  = "all"
  mode     = "always-on"

  # Raise both once anything in-memory (rate limiters, caches) moves to Postgres — a second
  # instance silently doubles every in-process limit.
  min_scale = 1
  max_scale = 1

  health_check_path = "/healthz"

  # Migrations run here — once per deploy, before traffic, from this exact image. Gates the
  # rollout: if it fails the deploy is aborted and the previous version keeps serving.
  release_command = ["sh", "/app/src/backend/docker-release.sh"]

  cpu_limit    = var.app_cpu_limit
  memory_limit = var.app_memory_limit

  env = {
    {{ENV_PREFIX}}_ENV    = "production"
    {{ENV_PREFIX}}_DOMAIN = var.domain
    PORT                  = "8000"
    LOG_LEVEL             = "info"
  }

  # DATABASE_URL (owner) is auto-injected by the platform — do not set it here (user env wins).
}
