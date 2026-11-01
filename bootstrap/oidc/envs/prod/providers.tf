
provider "aws" {
  region = var.aws_region

  allowed_account_ids = ["285034436054"]

  default_tags {
    tags = {
      Project     = "CanadaTechIntelligence"
      Environment = "prod"
      ManagedBy   = "Terraform"
      Component   = "GitHubOIDC"
    }
  }
}
