
module "github_oidc" {
  source = "../../modules/github-oidc"

  github_repository           = var.github_repository
  role_name                   = "cti-github-oidc-prod"
  environment                 = "prod"
  create_github_oidc_provider = var.create_github_oidc_provider

  tags = {
    Project     = "CanadaTechIntelligence"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}


