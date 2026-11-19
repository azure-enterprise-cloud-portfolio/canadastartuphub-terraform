
# ============================================================
# Canada Tech Intelligence
# Production Cognito Authentication
# ============================================================

module "cognito" {
  source = "../../modules/cognito"

  project     = var.project
  environment = var.environment

  # Google Sign-In
  enable_google_login  = true
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret

  # Production OAuth callback URL
  oauth_callback_urls = [
    "https://canadatechintelligence.ca/auth/callback"
  ]

  # Production logout redirect URL
  oauth_logout_urls = [
    "https://canadatechintelligence.ca/login"
  ]
}
