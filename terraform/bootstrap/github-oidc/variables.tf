variable "state_bucket_name" {
  description = "Central state bucket. Same name as in backend.tf."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "state_bucket_name must be a valid S3 bucket name."
  }
}

variable "aws_region" {
  description = "AWS region. ca-central-1 only."
  type        = string
  default     = "ca-central-1"

  validation {
    condition     = var.aws_region == "ca-central-1"
    error_message = "This project runs in ca-central-1 only."
  }
}

variable "prod_account_id" {
  description = "Prod AWS account (holds the state bucket)."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.prod_account_id))
    error_message = "prod_account_id must be a 12-digit AWS account ID."
  }
}

variable "dev_account_id" {
  description = "Dev AWS account."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.dev_account_id))
    error_message = "dev_account_id must be a 12-digit AWS account ID."
  }
}

variable "dev_aws_profile" {
  description = "Local AWS CLI profile for the dev account."
  type        = string
  default     = "csh-dev-admin"
}

variable "create_dev_oidc_provider" {
  description = "Create the GitHub OIDC provider in the dev account (true) or use the existing one (false)."
  type        = bool
  default     = true
}

variable "name_prefix" {
  description = "Prefix for role names."
  type        = string
  default     = "canadastartuphub"
}

variable "github_repository" {
  description = "owner/name of the only GitHub repository allowed to assume the roles."
  type        = string
  default     = "azure-enterprise-cloud-portfolio/canadastartuphub"
}