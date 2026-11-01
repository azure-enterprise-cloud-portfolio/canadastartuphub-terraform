variable "state_bucket_name" {
  description = "Name of the central S3 bucket used for Terraform remote state. Set this in the local gitignored terraform.tfvars during bootstrap."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "state_bucket_name must be a valid S3 bucket name."
  }
}

variable "aws_region" {
  description = "AWS region for the Terraform state bucket. This project uses ca-central-1 only."
  type        = string
  default     = "ca-central-1"

  validation {
    condition     = var.aws_region == "ca-central-1"
    error_message = "This project runs in ca-central-1 only."
  }
}

variable "aws_account_id" {
  description = "The only AWS account this root may run against. Terraform refuses to plan or apply if the current credentials belong to any other account. Set in terraform.tfvars."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID."
  }
}

variable "name_prefix" {
  description = "Project tag value. Matches the repository and existing AWS resources."
  type        = string
  default     = "canadastartuphub"
}

variable "noncurrent_state_retention_days" {
  description = "Number of days an overwritten Terraform state version is retained for rollback."
  type        = number
  default     = 90

  validation {
    condition     = var.noncurrent_state_retention_days >= 30
    error_message = "noncurrent_state_retention_days must be at least 30 days."
  }
}

variable "admin_principal_arns" {
  description = "IAM role ARN patterns (wildcards allowed) permitted to change the state bucket's configuration or delete state objects. Every other principal is denied by the bucket policy. Set in the local gitignored terraform.tfvars."
  type        = list(string)

  validation {
    condition     = length(var.admin_principal_arns) > 0
    error_message = "At least one admin principal is required, or the bucket becomes unmanageable."
  }

  # A bare "*" or a broad path wildcard would match (nearly) everyone and
  # silently turn the deny statements off. Require an IAM role ARN whose final
  # segment contains a real role name, not just wildcards.
  validation {
    condition = alltrue([
      for arn in var.admin_principal_arns :
      can(regex("^arn:aws:iam::[0-9]{12}:role/(.*/)?[^/]*[A-Za-z0-9_+=,.@-]{8,}[^/]*$", arn))
    ])
    error_message = "Each admin_principal_arns entry must be an IAM role ARN whose role name contains at least 8 non-wildcard characters."
  }

  # An admin role from another account would never match this account's
  # principals, locking every real admin out of the bucket configuration.
  validation {
    condition = alltrue([
      for arn in var.admin_principal_arns :
      startswith(arn, "arn:aws:iam::${var.aws_account_id}:role/")
    ])
    error_message = "Every admin_principal_arns entry must be a role in aws_account_id's account."
  }
}

variable "dev_state_principal_arns" {
  description = "Dev account CI roles allowed to use dev/* in the state bucket."
  type        = list(string)
  default     = []
}