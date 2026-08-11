terraform {
  required_version = ">= 1.6"

  required_providers {
    fpcloud = {
      source  = "fogpipe/fpcloud"
      version = "~> 0.10"
    }
  }

  # LOCAL state on purpose: bootstrap creates the bucket that stores every other module's
  # state, so it can't keep its own state there (chicken-and-egg). terraform.tfstate stays on
  # disk and is gitignored. This is the one irreducible seed — small and rarely changes.
}

provider "fpcloud" {}

# The project (foundation). adopt_existing so a project created out-of-band is taken over
# instead of 409ing.
resource "fpcloud_project" "{{PROJECT_SNAKE}}" {
  name           = var.project
  org            = var.org
  egress         = "https"
  adopt_existing = true
}

# The tofu state bucket (fpcloud object storage, Garage-backed). The database/application
# modules use this as their S3 backend — no AWS. Exposes an owner S3 key + endpoint + region.
resource "fpcloud_bucket" "state" {
  name    = var.state_bucket
  project = fpcloud_project.{{PROJECT_SNAKE}}.id
}
