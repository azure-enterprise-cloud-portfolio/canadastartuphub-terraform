variable "name_prefix" {
  description = "Prefix for resource names, e.g. cti-dev or cti-prod."
  type        = string
}

variable "domain" {
  description = "Sending domain to verify in SES."
  type        = string
}

variable "from_address" {
  description = "The only From address the application may send as."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[a-z]{2,}$", var.from_address))
    error_message = "from_address must be a valid email address."
  }
}

variable "mail_from_subdomain" {
  description = "Custom MAIL FROM subdomain (SPF alignment). Must not already be in use."
  type        = string
  default     = "mail"
}

variable "manage_dns" {
  description = "Create the SES DNS records in Route 53."
  type        = bool
  default     = true
}

variable "route53_zone_id" {
  description = "Route 53 zone for the domain. Required when manage_dns = true."
  type        = string
  default     = null
}

variable "create_dmarc_record" {
  description = "Create a _dmarc TXT record (p=none). Only one DMARC record may exist."
  type        = bool
  default     = false
}

variable "alert_email" {
  description = "Email subscribed to SES reputation alarms. Null = no subscription."
  type        = string
  default     = null
}

variable "bounce_rate_threshold" {
  description = "Alarm when bounce rate reaches this fraction (0.04 = 4%). AWS reviews at ~5%."
  type        = number
  default     = 0.04
}

variable "complaint_rate_threshold" {
  description = "Alarm when complaint rate reaches this fraction (0.0008 = 0.08%). AWS reviews at ~0.1%."
  type        = number
  default     = 0.0008
}

variable "app_inbox" {
  description = "Where the application delivers contact/submission mail. Null = from_address."
  type        = string
  default     = null
}

variable "create_amplify_compute_role" {
  description = "Create an Amplify SSR compute role with SES send permission."
  type        = bool
  default     = false
}

variable "attach_to_role_names" {
  description = "Existing IAM role names to grant SES send permission."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Extra tags for taggable resources."
  type        = map(string)
  default     = {}
}