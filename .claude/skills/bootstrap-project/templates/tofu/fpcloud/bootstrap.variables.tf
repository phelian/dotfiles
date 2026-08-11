variable "project" {
  description = "fpcloud project name"
  type        = string
  default     = "{{PROJECT}}"
}

variable "org" {
  description = "fpcloud org that owns the project"
  type        = string
  default     = "{{ORG}}"
}

variable "state_bucket" {
  description = "Bucket holding the database + application tofu state"
  type        = string
  default     = "{{PROJECT}}-tfstate"
}
