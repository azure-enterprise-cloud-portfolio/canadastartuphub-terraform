variable "aws_region" {
  type    = string
  default = "ca-central-1"
}

variable "github_repository" {
  type        = string
  description = "This Terraform repo (owner/repo); GitHub Actions runs from it may assume the CI role."
  default     = "azure-enterprise-cloud-portfolio/canadastartuphub-terraform"
}

variable "create_github_oidc_provider" {
  type        = bool
  description = "Set false if the account already has a GitHub OIDC provider (only one is allowed per account)."
  default     = true
}
