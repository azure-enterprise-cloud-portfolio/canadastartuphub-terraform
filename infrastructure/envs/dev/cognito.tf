
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
# - LinkedIn OAuth credentials
# - Microsoft Entra ID app registrations and credentials
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

  # Preserve existing working Google authentication.
  enable_google_login = true

  # Credentials supplied securely through Terraform variables.
  # Never hardcode Google OAuth credentials here.
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret

  # ----------------------------------------------------------
  # 3. LinkedIn OpenID Connect Authentication
  # ----------------------------------------------------------

  # Preserve existing LinkedIn enablement configuration.
  enable_linkedin_login = var.enable_linkedin_login

  # Credentials supplied securely through Terraform variables.
  # Never hardcode LinkedIn credentials here.
  linkedin_client_id     = var.linkedin_client_id
  linkedin_client_secret = var.linkedin_client_secret

  # ----------------------------------------------------------
  # 4. Microsoft Entra ID OpenID Connect Authentication
  # ----------------------------------------------------------
  #
  # DEV Microsoft application:
  # CTI - Development
  #
  # Provider name: Microsoft
  # Provider type: OIDC
  #
  # OIDC issuer:
  # https://login.microsoftonline.com/<tenant-id>/v2.0
  #
  # Microsoft authorized redirect URI:
  # https://cti-dev-auth.auth.ca-central-1.amazoncognito.com/oauth2/idpresponse
  #
  # Microsoft is disabled by default until the DEV
  # credentials and GitHub Actions workflow are configured.
  # ----------------------------------------------------------

  enable_microsoft_login = var.enable_microsoft_login

  # Directory (tenant) ID from Microsoft Entra ID.
  microsoft_tenant_id = var.microsoft_tenant_id

  # Credentials supplied through secure Terraform variables.
  # Never hardcode Microsoft Client Secrets in source control.
  microsoft_client_id     = var.microsoft_client_id
  microsoft_client_secret = var.microsoft_client_secret

  # ----------------------------------------------------------
  # 5. DEV OAuth Callback URLs
  # ----------------------------------------------------------
  #
  # Cognito requires an exact redirect_uri match.
  #
  # DEV website:
  # https://dev.canadatechintelligence.ca
  #
  # Local development:
  # http://localhost:3000
  #
  # These URLs must be supported by the application OAuth
  # callback implementation.
  # ----------------------------------------------------------

  oauth_callback_urls = [
    "https://dev.canadatechintelligence.ca/auth/callback",
    "http://localhost:3000/auth/callback",
  ]

  # ----------------------------------------------------------
  # 6. DEV OAuth Logout URLs
  # ----------------------------------------------------------
  #
  # Cognito redirects to an approved logout URL after
  # federated logout.
  # ----------------------------------------------------------

  oauth_logout_urls = [
    "https://dev.canadatechintelligence.ca/login",
    "http://localhost:3000/login",
  ]
}

