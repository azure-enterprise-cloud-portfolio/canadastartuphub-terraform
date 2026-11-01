
provider "aws" {
  region = var.aws_region

  allowed_account_ids = ["959856141465"]

  default_tags {
    tags = {
      Project     = "CanadaTechIntelligence"
      Environment = "dev"
      ManagedBy   = "Terraform"
      Component   = "GitHubOIDC"
    }
  }
}

