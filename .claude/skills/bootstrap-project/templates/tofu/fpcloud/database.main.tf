terraform {
  required_version = ">= 1.6"

  required_providers {
    fpcloud = {
      source  = "fogpipe/fpcloud"
      version = "~> 0.10"
    }
  }

  # State in the fpcloud bucket created by tofu/bootstrap. Auth is the gitignored
  # [{{PROJECT}}-state] AWS profile that `just s3-profile` writes once — nothing secret is
  # committed. use_path_style + skip_* are required for a non-AWS S3 (Garage) endpoint.
  #
  # `bucket` must be bootstrap's `state_bucket_alias` output, not the display name, and tofu
  # forbids interpolation in backend config — paste the literal value after bootstrap applies.
  backend "s3" {
    bucket    = "{{STATE_BUCKET}}"
    key       = "database/terraform.tfstate"
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

# Project is owned by tofu/bootstrap; reference it by name.
data "fpcloud_project" "{{PROJECT_SNAKE}}" {
  name = var.project
}

# Managed Postgres. Connection creds are never exposed to tofu — the platform injects
# DATABASE_URL into the app from the CNPG secret; this module just provisions the db.
resource "fpcloud_database" "db" {
  project_id = data.fpcloud_project.{{PROJECT_SNAKE}}.id
  name       = var.db_name
  version    = "17"
  cpu        = var.db_cpu
  memory     = var.db_memory
  storage    = var.db_storage

  backup = {
    enabled   = true
    schedule  = "0 3 * * *"
    retention = "30d"
  }
}
