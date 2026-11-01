provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.aws_account_id]

  default_tags {
    tags = {
      Project     = var.name_prefix
      Environment = "shared"
      ManagedBy   = "terraform"
      Component   = "bootstrap-backend"
      Repository  = "azure-enterprise-cloud-portfolio/canadastartuphub"
    }
  }
}
