# Prod account: uses your current login (AWS_PROFILE).
provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [var.prod_account_id]

  default_tags {
    tags = {
      Project     = var.name_prefix
      Environment = "shared"
      ManagedBy   = "terraform"
      Component   = "bootstrap-github-oidc"
      Repository  = var.github_repository
    }
  }
}

# Dev account: uses the dev SSO profile.
provider "aws" {
  alias               = "dev"
  region              = var.aws_region
  profile             = var.dev_aws_profile
  allowed_account_ids = [var.dev_account_id]

  default_tags {
    tags = {
      Project     = var.name_prefix
      Environment = "shared"
      ManagedBy   = "terraform"
      Component   = "bootstrap-github-oidc"
      Repository  = var.github_repository
    }
  }
}