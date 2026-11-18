# ------------------------------------------------------------
# Google OAuth Authentication
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
