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

# --- SES -----------------------------------------------------------------------
variable "ses_from_address" {
  description = "The only From address the dev application may send as."
  type        = string
  default     = "contact@dev.canadatechintelligence.ca"
}

variable "ses_app_inbox" {
  description = "Real mailbox the dev application delivers to."
  type        = string
  default     = "contact@canadatechintelligence.ca"
}

variable "ses_alert_email" {
  description = "Receives SES reputation alarms. Null = no emails from dev."
  type        = string
  default     = null
}

variable "ses_test_recipients" {
  description = "Addresses dev may send to while in the SES sandbox."
  type        = list(string)
  default     = ["contact@canadatechintelligence.ca"]
}

variable "ses_create_amplify_compute_role" {
  description = "Create an Amplify compute role for a dev Amplify app."
  type        = bool
  default     = false
}


output "cognito_user_pool_id" {
  description = "CTI development Cognito User Pool ID"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "CTI development web client ID"
  value       = module.cognito.user_pool_client_id
}

output "cognito_user_pool_arn" {
  description = "CTI development User Pool ARN"
  value       = module.cognito.user_pool_arn
}

output "cognito_admin_group_name" {
  description = "CTI Cognito administrator group"
  value       = module.cognito.admin_group_name
}
