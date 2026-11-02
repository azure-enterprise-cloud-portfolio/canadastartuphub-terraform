variable "aws_region" {
  description = "AWS region for this environment."
  type        = string
  default     = "ca-central-1"
}

variable "domain" {
  description = "Primary domain (existing public hosted zone in this account)."
  type        = string
  default     = "canadatechintelligence.ca"
}

variable "dev_zone_name_servers" {
  description = "Name servers of dev.canadatechintelligence.ca in the dev account."
  type        = list(string)
  default = [
    "ns-1665.awsdns-16.co.uk",
    "ns-497.awsdns-62.com",
    "ns-879.awsdns-45.net",
    "ns-1352.awsdns-41.org",
  ]

  validation {
    condition = length(var.dev_zone_name_servers) == 4 && alltrue([
      for ns in var.dev_zone_name_servers :
      can(regex("^ns-[0-9]+\\.awsdns-[0-9]+\\.(com|net|org|co\\.uk)$", ns))
    ])
    error_message = "dev_zone_name_servers must be the 4 real Route 53 name servers of the dev zone (no placeholders, no trailing dot)."
  }
}