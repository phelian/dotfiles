variable "project" {
  description = "fpcloud project name (owned by tofu/bootstrap)"
  type        = string
  default     = "{{PROJECT}}"
}

variable "registry" {
  description = "Image registry path — must match the justfile's `registry`"
  type        = string
  default     = "registry.cloud.fogpipe.com/{{ORG}}/{{PROJECT}}"
}

# Wired in from the current git sha by `just tf-app` (TF_VAR_image_tag).
variable "image_tag" {
  type = string
}

variable "slug" {
  description = "Globally unique vanity hostname label"
  type        = string
  default     = "{{PROJECT}}"
}

variable "domain" {
  type    = string
  default = "{{DOMAIN}}"
}

variable "app_cpu_limit" {
  type    = string
  default = "500m"
}

variable "app_memory_limit" {
  type    = string
  default = "512Mi"
}
