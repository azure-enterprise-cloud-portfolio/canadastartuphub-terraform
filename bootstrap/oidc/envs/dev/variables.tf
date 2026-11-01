
variable "aws_region" {
  description = "AWS region for CTI production infrastructure."
  type        = string
  default     = "ca-central-1"
}

variable "github_repository" {
  description = "GitHub repository authorized to assume the AWS deployment role."
  type        = string
  default     = "azure-enterprise-cloud-portfolio/canadastartuphub-terraform"
}

variable "create_github_oidc_provider" {
  description = "Create the GitHub OIDC provider only if it does not already exist in this AWS account."
  type        = bool
  default     = false
}
