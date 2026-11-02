variable "zone_name" {
  description = "DNS name of the public hosted zone, e.g. dev.canadatechintelligence.ca."
  type        = string

  validation {
    condition     = can(regex("^([a-z0-9-]+\\.)+[a-z]{2,}$", var.zone_name))
    error_message = "zone_name must be a lowercase domain name without a trailing dot."
  }
}

variable "comment" {
  description = "Description shown in the Route 53 console."
  type        = string
  default     = "Managed by Terraform"
}

variable "force_destroy" {
  description = "Allow terraform destroy to delete the zone even if it still has records."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Extra tags for the zone."
  type        = map(string)
  default     = {}
}