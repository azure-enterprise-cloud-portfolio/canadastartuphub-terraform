variable "name_prefix" {
  description = "Prefix for named resources (configuration set, IAM policy)."
  type        = string
  default     = "canadastartuphub"
}

variable "environment" {
  description = "Environment name, used in resource names and the IAM policy path."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be \"dev\" or \"prod\"."
  }
}

variable "hosted_zone_name" {
  description = "Existing public Route 53 hosted zone. Looked up read-only; never created, imported or modified."
  type        = string
}

variable "identity_domain" {
  description = "Domain verified as the SES identity. Must be the hosted zone apex or a subdomain of it."
  type        = string
}

variable "mail_from_subdomain" {
  description = "Label for the custom MAIL FROM domain (<label>.<identity_domain>). It must be a name with no existing records."
  type        = string
  default     = "bounce"
}

variable "sender_address" {
  description = "The only From address the send policy allows. Must belong to identity_domain."
  type        = string
}

variable "allowed_recipients" {
  description = "Recipients the send policy allows (ses:Recipients). Empty list means no recipient restriction."
  type        = list(string)
  default     = []
}

variable "dkim_key_length" {
  description = "Easy DKIM key length."
  type        = string
  default     = "RSA_2048_BIT"
}

variable "record_ttl" {
  description = "TTL in seconds for the SES DNS records this module creates."
  type        = number
  default     = 1800
}
