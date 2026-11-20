
# ============================================================
# Canada Tech Intelligence
# Amazon Cognito - Federated Authentication Local Values
# ============================================================

locals {
  # ----------------------------------------------------------
  # Enable federation when any external provider is enabled
  # ----------------------------------------------------------

  enable_federated_login = (
    var.enable_google_login ||
    var.enable_linkedin_login ||
    var.enable_microsoft_login
  )

  # ----------------------------------------------------------
  # Supported Identity Providers
  # ----------------------------------------------------------
  #
  # COGNITO must always remain enabled for email/password.
  #
  # Add only external identity providers enabled in the
  # current Terraform environment.
  # ----------------------------------------------------------

  enabled_identity_providers = concat(
    ["COGNITO"],

    # Google OAuth
    var.enable_google_login ? [
      aws_cognito_identity_provider.google[0].provider_name
    ] : [],

    # LinkedIn OpenID Connect
    var.enable_linkedin_login ? [
      aws_cognito_identity_provider.linkedin[0].provider_name
    ] : [],

    # Microsoft Entra ID OpenID Connect
    var.enable_microsoft_login ? [
      aws_cognito_identity_provider.microsoft[0].provider_name
    ] : []
  )
}

