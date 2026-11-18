
variable "project" {
  description = "CTI project identifier"
  type        = string
}

variable "environment" {
  description = "Deployment environment: dev or prod"
  type        = string

  validation {
    condition = contains(
      ["dev", "prod"],
      var.environment
    )

    error_message = "Environment must be dev or prod."
  }
}


# --- Google OAuth Authentication ----------------------------

variable "enable_google_login" {
  description = "Enable Google Sign-In"
  type        = bool
  default     = false
}

variable "google_client_id" {
  description = "Google OAuth Client ID"
  type        = string
  default     = null
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth Client Secret"
  type        = string
  default     = null
  sensitive   = true
}

variable "oauth_callback_urls" {
  description = "Cognito OAuth callback URLs"
  type        = list(string)
  default     = []
}

variable "oauth_logout_urls" {
  description = "Cognito OAuth logout URLs"
  type        = list(string)
  default     = []
}

