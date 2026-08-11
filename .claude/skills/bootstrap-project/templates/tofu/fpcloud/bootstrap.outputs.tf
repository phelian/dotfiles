# These feed the database/application S3 backends. `just s3-profile` reads them from this
# module's local state and writes them to the gitignored [{{PROJECT}}-state] AWS profile.

output "project" {
  description = "Project name — the database/application modules look it up by name."
  value       = fpcloud_project.{{PROJECT_SNAKE}}.name
}

output "state_bucket" {
  description = "State bucket name (the fpcloud display name)."
  value       = fpcloud_bucket.state.name
}

output "state_bucket_alias" {
  description = "The bucket's S3 name — this is what the other modules' backend `bucket` must be."
  value       = fpcloud_bucket.state.global_alias
}

output "s3_endpoint" {
  description = "S3 endpoint for the state bucket (AWS_ENDPOINT_URL_S3)."
  value       = fpcloud_bucket.state.endpoint
}

output "s3_region" {
  description = "S3 region for the state bucket (AWS_REGION)."
  value       = fpcloud_bucket.state.region
}

output "s3_access_key_id" {
  description = "S3 access key id for the state bucket (AWS_ACCESS_KEY_ID)."
  value       = fpcloud_bucket.state.access_key_id
  sensitive   = true
}

output "s3_secret_access_key" {
  description = "S3 secret for the state bucket (AWS_SECRET_ACCESS_KEY)."
  value       = fpcloud_bucket.state.secret_access_key
  sensitive   = true
}
