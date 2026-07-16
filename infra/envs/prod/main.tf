module "amplify_app" {
  source = "../../modules/amplify-app"

  app_name       = "canadastartuphub"
  repository_url = var.repository_url
  github_token   = var.github_token
  branch_name    = var.amplify_branch
}

module "amplify_domain" {
  source = "../../modules/amplify-domain"

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  domain_name        = var.domain_name
  amplify_app_id     = module.amplify_app.app_id
  amplify_branch     = module.amplify_app.branch_name
  create_hosted_zone = true
  certificate_type   = "AMPLIFY_MANAGED"

  # "" maps the apex (canadastartuphub.ca), "www" serves www.
  subdomains = ["", "www"]
}
