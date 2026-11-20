
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
  #
  # Preserve existing production Google Sign-In.
  # ----------------------------------------------------------

  enable_google_login  = true
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret

  # ----------------------------------------------------------
  # LinkedIn OpenID Connect Authentication
  # ----------------------------------------------------------
  #
  # Production LinkedIn application: CTI - Production
  # Credentials are supplied using GitHub Actions secrets.
  #
  # Do not place credentials in Terraform source files.
  # ----------------------------------------------------------

  enable_linkedin_login  = var.enable_linkedin_login
  linkedin_client_id     = var.linkedin_client_id
  linkedin_client_secret = var.linkedin_client_secret

  # ----------------------------------------------------------
  # Microsoft Entra ID OpenID Connect Authentication
  # ----------------------------------------------------------
  #
  # Production Microsoft application: CTI - Production
  #
  # Credentials are supplied using GitHub Actions secrets.
  # Do not place credentials in Terraform source files.
  #
  # Enable only after successful DEV authentication testing
  # and review of the PROD Terraform plan.
  # ----------------------------------------------------------

  enable_microsoft_login  = var.enable_microsoft_login
  microsoft_tenant_id     = var.microsoft_tenant_id
  microsoft_client_id     = var.microsoft_client_id
  microsoft_client_secret = var.microsoft_client_secret

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

