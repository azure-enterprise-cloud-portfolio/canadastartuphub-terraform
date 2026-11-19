
# ============================================================
# Canada Tech Intelligence
# DEV Cognito Authentication
# ============================================================
#
# This configuration manages Cognito authentication for DEV.
#
# DEV and PROD use separate:
# - AWS accounts
# - Cognito User Pools
# - Cognito App Clients
# - Google OAuth credentials
# - Callback and logout URLs
#
# DEV Website:
# https://dev.canadatechintelligence.ca
#
# DEV Cognito Domain:
# https://cti-dev-auth.auth.ca-central-1.amazoncognito.com
#
# AWS Region: ca-central-1
# ============================================================

module "cognito" {
  source = "../../modules/cognito"

  # ----------------------------------------------------------
  # 1. General Configuration
  # ----------------------------------------------------------

  project     = var.project
  environment = var.environment

  # ----------------------------------------------------------
  # 2. Google OAuth Authentication
  # ----------------------------------------------------------

  enable_google_login = true

  # Credentials supplied securely through Terraform variables.
  # Never hardcode Google OAuth credentials here.

  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret

  # ----------------------------------------------------------
  # 3. DEV OAuth Callback URLs
  # ----------------------------------------------------------
  #
  # Cognito requires an exact redirect_uri match.
  #
  # Production DEV website:
  # https://dev.canadatechintelligence.ca
  #
  # Local development:
  # http://localhost:3000
  #
  # These URLs must also be supported by the application's
  # OAuth callback implementation.
  # ----------------------------------------------------------

  oauth_callback_urls = [
    "https://dev.canadatechintelligence.ca/auth/callback",
    "http://localhost:3000/auth/callback",
  ]

  # ----------------------------------------------------------
  # 4. DEV OAuth Logout URLs
  # ----------------------------------------------------------
  #
  # After federated logout, Cognito redirects the user
  # to one of the registered logout URLs.
  #
  # Logout URLs must match the requested logout_uri.
  # ----------------------------------------------------------

  oauth_logout_urls = [
    "https://dev.canadatechintelligence.ca/login",
    "http://localhost:3000/login",
  ]
}
