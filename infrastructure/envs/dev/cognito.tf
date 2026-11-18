
module "cognito" {
  source = "../../modules/cognito"

  project     = var.project
  environment = var.environment

  # Google Sign-In
  enable_google_login  = false
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret

  # OAuth callback URL
  oauth_callback_urls = [
    "https://dev.canadatechintelligence.ca/auth/callback"
  ]

  # Logout redirect URL
  oauth_logout_urls = [
    "https://dev.canadatechintelligence.ca/login"
  ]
}
