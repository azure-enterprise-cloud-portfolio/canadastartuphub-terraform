variable "aws_region" {
  description = "AWS region for this environment."
  type        = string
  default     = "ca-central-1"
}

variable "project" {
  description = "Project name, used in tags."
  type        = string
  default     = "canadatechintelligence-platform"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,38}[a-z0-9]$", var.project))
    error_message = "project must be lowercase letters, numbers and hyphens (3-40 chars), no spaces."
  }
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "dev_domain" {
  description = "Dev subdomain hosted in this account."
  type        = string
  default     = "dev.canadatechintelligence.ca"
}