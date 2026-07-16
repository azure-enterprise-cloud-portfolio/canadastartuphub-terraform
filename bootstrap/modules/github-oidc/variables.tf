variable "github_repository" {
  type        = string
  description = "GitHub repository allowed to assume the CI role, as owner/repo."

  validation {
    condition     = can(regex("^[^/]+/[^/]+$", var.github_repository))
    error_message = "Must be in owner/repo form, e.g. my-org/my-repo."
  }
}

variable "role_name" {
  type        = string
  description = "Name of the IAM role GitHub Actions assumes."
}

variable "create_github_oidc_provider" {
  type        = bool
  description = "Create the GitHub OIDC identity provider. Set false to reuse one that already exists in the account (only one is allowed per account)."
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
