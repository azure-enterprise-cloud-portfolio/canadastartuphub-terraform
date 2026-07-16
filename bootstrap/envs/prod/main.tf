module "github_oidc" {
  source = "../../modules/github-oidc"

  github_repository           = var.github_repository
  role_name                   = "canadastartuphub-github-actions"
  create_github_oidc_provider = var.create_github_oidc_provider
}
