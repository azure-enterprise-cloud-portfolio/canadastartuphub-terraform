module "github_oidc" {
  source = "../../modules/github-oidc"

  github_repository           = var.github_repository
  role_name                   = "cti-github-oidc-dev"
  environment                 = "dev"
  create_github_oidc_provider = var.create_github_oidc_provider

  tags = {
    Project     = "CanadaTechIntelligence"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}