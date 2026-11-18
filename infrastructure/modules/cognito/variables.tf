
variable "project" {
  description = "CTI project identifier"
  type        = string
}

variable "environment" {
  description = "Deployment environment: dev or prod"
  type        = string

  validation {
    condition = contains(
      ["dev", "prod"],
      var.environment
    )

    error_message = "Environment must be dev or prod."
  }
}
