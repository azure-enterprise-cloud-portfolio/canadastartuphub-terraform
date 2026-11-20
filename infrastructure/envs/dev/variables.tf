
# ============================================================
# Canada Tech Intelligence
# Development Environment - Terraform Variables
# ============================================================

# --- AWS Configuration ---------------------------------------

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

# --- Amazon SES ----------------------------------------------

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

# --- Google OAuth --------------------------------------------

variable "google_client_id" {
  description = "Google OAuth Client ID for CTI development."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(trimspace(var.google_client_id)) > 0
    error_message = "DEV Google OAuth Client ID must not be empty."
  }
}

variable "google_client_secret" {
  description = "Google OAuth Client Secret for CTI development."
  type        = string
  sensitive   = true
  nullable    = false

  validation {
    condition     = length(trimspace(var.google_client_secret)) > 0
    error_message = "DEV Google OAuth Client Secret must not be empty."
  }
}

# --- LinkedIn OAuth / OIDC ----------------------------------

variable "enable_linkedin_login" {
  description = "Enable LinkedIn OIDC sign-in for CTI development."
  type        = bool
  default     = false
  nullable    = false
}

variable "linkedin_client_id" {
  description = "LinkedIn OpenID Connect Client ID for CTI development."
  type        = string
  sensitive   = true
  default     = null

  validation {
    condition = (
      !var.enable_linkedin_login ||
      (
        var.linkedin_client_id != null &&
        try(length(trimspace(var.linkedin_client_id)) > 0, false)
      )
    )

    error_message = "DEV LinkedIn Client ID is required when LinkedIn login is enabled."
  }
}

variable "linkedin_client_secret" {
  description = "LinkedIn OpenID Connect Client Secret for CTI development."
  type        = string
  sensitive   = true
  default     = null

  validation {
    condition = (
      !var.enable_linkedin_login ||
      (
        var.linkedin_client_secret != null &&
        try(length(trimspace(var.linkedin_client_secret)) > 0, false)
      )
    )

    error_message = "DEV LinkedIn Client Secret is required when LinkedIn login is enabled."
  }
}

# --- Microsoft Entra ID OAuth / OIDC --------------------------
#
# Microsoft authentication uses the existing Cognito User Pool.
#
# DEV application registration:
# CTI - Development
#
# Separate Microsoft credentials must be used for PROD.
#
# Microsoft login remains disabled until explicitly enabled.
# ------------------------------------------------------------

variable "enable_microsoft_login" {
  description = "Enable Microsoft Entra ID OIDC sign-in for CTI development."
  type        = bool
  default     = false
  nullable    = false
}

variable "microsoft_tenant_id" {
  description = "Microsoft Entra Directory (Tenant) ID for CTI development."
  type        = string
  default     = null

  validation {
    condition = (
      !var.enable_microsoft_login ||
      (
        var.microsoft_tenant_id != null &&
        can(regex(
          "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$",
          var.microsoft_tenant_id
        ))
      )
    )

    error_message = "DEV Microsoft Entra Tenant ID must be a valid GUID when Microsoft login is enabled."
  }
}

variable "microsoft_client_id" {
  description = "Microsoft Entra Application Client ID for CTI development."
  type        = string
  sensitive   = true
  default     = null

  validation {
    condition = (
      !var.enable_microsoft_login ||
      (
        var.microsoft_client_id != null &&
        try(length(trimspace(var.microsoft_client_id)) > 0, false)
      )
    )

    error_message = "DEV Microsoft Client ID is required when Microsoft login is enabled."
  }
}

variable "microsoft_client_secret" {
  description = "Microsoft Entra Application Client Secret for CTI development."
  type        = string
  sensitive   = true
  default     = null

  validation {
    condition = (
      !var.enable_microsoft_login ||
      (
        var.microsoft_client_secret != null &&
        try(length(trimspace(var.microsoft_client_secret)) > 0, false)
      )
    )

    error_message = "DEV Microsoft Client Secret is required when Microsoft login is enabled."
  }
}



