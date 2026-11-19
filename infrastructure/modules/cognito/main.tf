
# ============================================================
# Canada Tech Intelligence
# Amazon Cognito User Pool and Authentication
# ============================================================

# ------------------------------------------------------------
# 0. Federated Authentication Configuration
# ------------------------------------------------------------

locals {
  # Enable OAuth when Google or LinkedIn is enabled.
  enable_federated_login = (
    var.enable_google_login ||
    var.enable_linkedin_login
  )

  # Preserve Cognito email/password authentication.
  # Include only enabled external identity providers.
  enabled_identity_providers = concat(
    ["COGNITO"],
    var.enable_google_login ? [
      aws_cognito_identity_provider.google[0].provider_name
    ] : [],
    var.enable_linkedin_login ? [
      aws_cognito_identity_provider.linkedin[0].provider_name
    ] : []
  )
}

# ------------------------------------------------------------
# 1. Cognito User Pool
# ------------------------------------------------------------

resource "aws_cognito_user_pool" "this" {
  name = "cti-${var.environment}-users"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  username_configuration {
    case_sensitive = false
  }

  user_pool_tier = "LITE"

  password_policy {
    minimum_length    = 12
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = "Verify your CTI account"
    email_message        = "Your verification code is {####}"
  }

  mfa_configuration = "OPTIONAL"

  software_token_mfa_configuration {
    enabled = true
  }

  tags = {
    Project     = "CanadaTechIntelligence"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# ------------------------------------------------------------
# 2. Google Identity Provider
# ------------------------------------------------------------
#
# Preserve the existing Google provider settings observed
# in DEV Cognito and the Terraform plan.
#
# Do not change working Google authentication when adding
# LinkedIn OIDC.
# ------------------------------------------------------------

resource "aws_cognito_identity_provider" "google" {
  count = var.enable_google_login ? 1 : 0

  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
    authorize_scopes = "openid email profile"

    # Existing Cognito Google provider endpoint settings.
    attributes_url = "https://people.googleapis.com/v1/people/me?personFields="

    attributes_url_add_attributes = "true"

    authorize_url = "https://accounts.google.com/o/oauth2/v2/auth"

    oidc_issuer = "https://accounts.google.com"

    token_request_method = "POST"

    token_url = "https://www.googleapis.com/oauth2/v4/token"
  }

  # Preserve existing Google attribute mappings.
  attribute_mapping = {
    email          = "email"
    email_verified = "email_verified"
    username       = "sub"
  }
}

# ------------------------------------------------------------
# 3. LinkedIn OpenID Connect Identity Provider
# ------------------------------------------------------------

resource "aws_cognito_identity_provider" "linkedin" {
  count = var.enable_linkedin_login ? 1 : 0

  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "LinkedIn"
  provider_type = "OIDC"

  provider_details = {
    client_id                 = var.linkedin_client_id
    client_secret             = var.linkedin_client_secret
    authorize_scopes          = "openid profile email"
    oidc_issuer               = "https://www.linkedin.com/oauth"
    attributes_request_method = "GET"
  }

  # LinkedIn may omit the email claim.
  # Application-side authentication must handle this safely.
  attribute_mapping = {
    email = "email"
    name  = "name"
  }

  # Validate credentials only when this resource is created.
  lifecycle {
    precondition {
      condition = (
        var.linkedin_client_id != null &&
        var.linkedin_client_secret != null &&
        try(length(trimspace(var.linkedin_client_id)) > 0, false) &&
        try(length(trimspace(var.linkedin_client_secret)) > 0, false)
      )

      error_message = "LinkedIn Client ID and Client Secret are required when LinkedIn login is enabled."
    }
  }
}

# ------------------------------------------------------------
# 4. Cognito Web Application Client
# ------------------------------------------------------------

resource "aws_cognito_user_pool_client" "web" {
  name         = "cti-${var.environment}-web"
  user_pool_id = aws_cognito_user_pool.this.id

  # Public browser client
  generate_secret = false

  # Existing email/password authentication
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  # Existing token validity
  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 7

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  enable_token_revocation       = true
  prevent_user_existence_errors = "ENABLED"

  # ----------------------------------------------------------
  # Cognito + Google + LinkedIn OAuth
  # ----------------------------------------------------------

  supported_identity_providers = local.enabled_identity_providers

  allowed_oauth_flows_user_pool_client = local.enable_federated_login

  allowed_oauth_flows = local.enable_federated_login ? [
    "code"
  ] : []

  allowed_oauth_scopes = local.enable_federated_login ? [
    "openid",
    "email",
    "profile"
  ] : []

  # Preserve existing callback and logout URLs.
  callback_urls = var.oauth_callback_urls
  logout_urls   = var.oauth_logout_urls
}

# ------------------------------------------------------------
# 5. Administrator Group
# ------------------------------------------------------------

resource "aws_cognito_user_group" "admin" {
  name         = "CTI_Admin"
  user_pool_id = aws_cognito_user_pool.this.id

  description = "Authorized CTI administrators"

  precedence = 1
}

# ------------------------------------------------------------
# 6. Cognito Hosted Domain
# ------------------------------------------------------------
#
# A hosted domain is needed when either Google
# or LinkedIn federation is enabled.
# ------------------------------------------------------------

resource "aws_cognito_user_pool_domain" "this" {
  count = local.enable_federated_login ? 1 : 0

  domain       = "cti-${var.environment}-auth"
  user_pool_id = aws_cognito_user_pool.this.id
}



