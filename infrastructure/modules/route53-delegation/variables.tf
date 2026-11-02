variable "parent_zone_name" {
  description = "Existing parent public hosted zone, e.g. canadatechintelligence.ca."
  type        = string
}

variable "subdomain" {
  description = "Label to delegate, e.g. dev (creates dev.<parent_zone_name>)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.subdomain))
    error_message = "subdomain must be a single lowercase label, e.g. dev."
  }
}

variable "name_servers" {
  description = "Name servers of the child hosted zone (usually 4)."
  type        = list(string)

  validation {
    condition     = length(var.name_servers) >= 2
    error_message = "Provide the child zone's name servers (at least 2, usually 4)."
  }
}

variable "ttl" {
  description = "TTL for the NS record, in seconds."
  type        = number
  default     = 172800
}