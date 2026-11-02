variable "github_repository" {
  type        = string
  description = "GitHub repository authorized to assume the IAM role (owner/repo)."

  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.github_repository))
    error_message = "Must be in owner/repo format."
  }
}

variable "role_name" {
  type        = string
  description = "IAM role name used by GitHub Actions."
}

variable "environment" {
  type        = string
  description = "GitHub Actions deployment environment: dev or prod."

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be dev or prod."
  }
}

variable "create_github_oidc_provider" {
  type        = bool
  description = "Create the GitHub OIDC provider or reuse the existing provider."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to AWS resources."
  default     = {}
}

variable "github_sub_claim_prefix" {
  type        = string
  description = "GitHub OIDC immutable subject prefix (repo:owner@ownerId/repo@repoId). Null = classic subject only."
  default     = null

  validation {
    condition     = var.github_sub_claim_prefix == null || can(regex("^repo:[^/@]+@[0-9]+/[^/@]+@[0-9]+$", var.github_sub_claim_prefix))
    error_message = "Must look like repo:owner@ownerId/repo@repoId (from gh api repos/<owner>/<repo>/actions/oidc/customization/sub)."
  }
}