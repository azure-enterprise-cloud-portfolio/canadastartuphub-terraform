variable "app_name" {
  type        = string
  description = "Amplify app name."
}

variable "repository_url" {
  type        = string
  description = "GitHub repository URL, e.g. https://github.com/owner/repo"
}

variable "github_token" {
  type        = string
  description = "GitHub token used once to install the Amplify webhook. Pass via TF_VAR_github_token."
  sensitive   = true
}

variable "branch_name" {
  type        = string
  description = "Branch that deploys to production."
  default     = "main"
}

variable "environment_variables" {
  type        = map(string)
  description = "App-level environment variables available at build time."
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
