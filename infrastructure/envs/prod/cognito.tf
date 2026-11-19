
# ============================================================
# Canada Tech Intelligence
# Production Cognito Authentication
# ============================================================

module "cognito" {
  source = "../../modules/cognito"

  project     = var.project
  environment = var.environment

  # ----------------------------------------------------------
  # Google OAuth Authentication
  # ----------------------------------------------------------

  enable_google_login  = true
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret

  # ----------------------------------------------------------
  # Production OAuth Callback URL
  # ----------------------------------------------------------

  oauth_callback_urls = [
    "https://canadatechintelligence.ca/auth/callback"
  ]

  # ----------------------------------------------------------
  # Production Logout Redirect URL
  # ----------------------------------------------------------

  oauth_logout_urls = [
    "https://canadatechintelligence.ca/login"
  ]
}
