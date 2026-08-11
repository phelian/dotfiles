variable "project" {
  description = "fpcloud project name (owned by tofu/bootstrap)"
  type        = string
  default     = "{{PROJECT}}"
}

variable "db_name" {
  type    = string
  default = "db"
}

variable "db_cpu" {
  type    = string
  default = "500m"
}

variable "db_memory" {
  type    = string
  default = "1Gi"
}

variable "db_storage" {
  type    = string
  default = "10Gi"
}
