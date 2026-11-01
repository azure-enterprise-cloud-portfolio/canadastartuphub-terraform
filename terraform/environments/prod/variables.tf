# Defaults hold the real, non-secret PROD values, so CI needs no tfvars file.
# Override locally with a terraform.tfvars (gitignored); see the .example.

variable "aws_region" {
  description = "AWS region. The project runs in ca-central-1 only."
  type        = string
  default     = "ca-central-1"

  validation {
    condition     = var.aws_region == "ca-central-1"
    error_message = "This project runs in ca-central-1 only."
  }
}

variable "hosted_zone_name" {
  description = "Existing Route 53 hosted zone (read-only lookup)."
  type        = string
  default     = "canadatechintelligence.ca"
}

variable "identity_domain" {
  description = "SES domain identity for PROD."
  type        = string
  default     = "canadatechintelligence.ca"
}

variable "mail_from_subdomain" {
  description = "Custom MAIL FROM label (<label>.<identity_domain>)."
  type        = string
  default     = "bounce"
}

variable "sender_address" {
  description = "The only From address PROD may send as."
  type        = string
  default     = "contact@canadatechintelligence.ca"
}

variable "allowed_recipients" {
  description = "The only recipients PROD may send to (the existing Microsoft 365 mailbox)."
  type        = list(string)
  default     = ["contact@canadatechintelligence.ca"]
}
