variable "aws_region" {
  type    = string
  default = "ca-central-1"
}

variable "domain_name" {
  type    = string
  default = "canadastartupdirectory.ca"
}

variable "repository_url" {
  type        = string
  description = "GitHub repository URL for the Next.js app."
}

variable "github_token" {
  type        = string
  description = "GitHub token for the Amplify webhook. Pass via TF_VAR_github_token, never commit."
  sensitive   = true
}

variable "amplify_branch" {
  type    = string
  default = "main"
}
