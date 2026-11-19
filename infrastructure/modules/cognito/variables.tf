
# ============================================================
# Canada Tech Intelligence
# Amazon Cognito Module - Terraform Variables
# ============================================================

# ------------------------------------------------------------
# 1. General Configuration
# ------------------------------------------------------------

variable "project" {
  description = "CTI project identifier"
  type        = string
}

variable "environment" {
  description = "Deployment environment: dev or prod"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be dev or prod."
  }
}

# ------------------------------------------------------------
# 2. Google OAuth Authentication
# ------------------------------------------------------------

variable "enable_google_login" {
  description = "Enable Google Sign-In"
  type        = bool
  default     = false
  nullable    = false
}

variable "google_client_id" {
  description = "Google OAuth Client ID"
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition = (
      !var.enable_google_login ||
      (
        var.google_client_id != null &&
        try(length(trimspace(var.google_client_id)) > 0, false)
      )
    )

    error_message = "Google Client ID is required when Google Login is enabled."
  }
}

variable "google_client_secret" {
  description = "Google OAuth Client Secret"
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition = (
      !var.enable_google_login ||
      (
        var.google_client_secret != null &&
        try(length(trimspace(var.google_client_secret)) > 0, false)
      )
    )

    error_message = "Google Client Secret is required when Google Login is enabled."
  }
}

# ------------------------------------------------------------
# 3. LinkedIn OpenID Connect Authentication
# ------------------------------------------------------------

variable "enable_linkedin_login" {
  description = "Enable LinkedIn Sign-In using OpenID Connect"
  type        = bool
  default     = false
  nullable    = false
}

variable "linkedin_client_id" {
  description = "LinkedIn OpenID Connect Client ID"
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition = (
      !var.enable_linkedin_login ||
      (
        var.linkedin_client_id != null &&
        try(length(trimspace(var.linkedin_client_id)) > 0, false)
      )
    )

    error_message = "LinkedIn Client ID is required when LinkedIn login is enabled."
  }
}

variable "linkedin_client_secret" {
  description = "LinkedIn OpenID Connect Client Secret"
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition = (
      !var.enable_linkedin_login ||
      (
        var.linkedin_client_secret != null &&
        try(length(trimspace(var.linkedin_client_secret)) > 0, false)
      )
    )

    error_message = "LinkedIn Client Secret is required when LinkedIn login is enabled."
  }
}

# ------------------------------------------------------------
# 4. Cognito OAuth Callback Configuration
# ------------------------------------------------------------

variable "oauth_callback_urls" {
  description = "Allowed callback URLs for Cognito OAuth"
  type        = list(string)
  default     = []
}

variable "oauth_logout_urls" {
  description = "Allowed logout redirect URLs for Cognito OAuth"
  type        = list(string)
  default     = []
}
