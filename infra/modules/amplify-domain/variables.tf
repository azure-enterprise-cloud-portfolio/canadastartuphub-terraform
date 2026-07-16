variable "domain_name" {
  type        = string
  description = "Root domain, e.g. canadastartupdirectory.ca"
}

variable "amplify_app_id" {
  type        = string
  description = "Existing Amplify app ID"
}

variable "amplify_branch" {
  type        = string
  description = "Amplify branch to map the domain to"
}

variable "subdomains" {
  type        = list(string)
  description = "Subdomain prefixes to map. Use \"\" for the apex."
  default     = ["", "www"]
}

variable "create_hosted_zone" {
  type        = bool
  description = "Create the Route 53 zone. Set false + pass hosted_zone_id if it already exists (shared across envs)."
  default     = true
}

variable "hosted_zone_id" {
  type        = string
  description = "Existing zone ID, required when create_hosted_zone = false."
  default     = null
}

variable "certificate_type" {
  type        = string
  description = "AMPLIFY_MANAGED (Amplify provisions & renews ACM) or CUSTOM (bring your own)."
  default     = "AMPLIFY_MANAGED"

  validation {
    condition     = contains(["AMPLIFY_MANAGED", "CUSTOM"], var.certificate_type)
    error_message = "certificate_type must be AMPLIFY_MANAGED or CUSTOM."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
