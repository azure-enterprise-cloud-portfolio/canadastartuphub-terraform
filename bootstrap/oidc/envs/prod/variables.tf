variable "aws_region" {
  description = "AWS region for CTI infrastructure."
  type        = string
  default     = "ca-central-1"
}

variable "github_repository" {
  description = "GitHub repository authorized to assume the AWS roles (owner/repo)."
  type        = string
  default     = "azure-enterprise-cloud-portfolio/canadastartuphub-terraform"
}

variable "github_sub_claim_prefix" {
  description = "GitHub OIDC immutable subject prefix. From: gh api repos/<owner>/<repo>/actions/oidc/customization/sub"
  type        = string
  default     = "repo:azure-enterprise-cloud-portfolio@233881372/canadastartuphub-terraform@1302272752"
}

variable "create_github_oidc_provider" {
  description = "Create the GitHub OIDC provider only if it does not already exist in this AWS account."
  type        = bool
  default     = false
}