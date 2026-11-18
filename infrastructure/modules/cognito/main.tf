
# ============================================================
# Canada Tech Intelligence
# Amazon Cognito User Pool and Authentication
# ============================================================

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

resource "aws_cognito_identity_provider" "google" {
  count = var.enable_google_login ? 1 : 0

  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
    authorize_scopes = "openid email profile"
  }

  attribute_mapping = {
    email          = "email"
    email_verified = "email_verified"
  }
}

# ------------------------------------------------------------
# 3. Cognito Web Application Client
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
  # Google OAuth
  # ----------------------------------------------------------

  supported_identity_providers = var.enable_google_login ? [
    "COGNITO",
    aws_cognito_identity_provider.google[0].provider_name
  ] : ["COGNITO"]

  allowed_oauth_flows_user_pool_client = var.enable_google_login

  allowed_oauth_flows = var.enable_google_login ? [
    "code"
  ] : []

  allowed_oauth_scopes = var.enable_google_login ? [
    "openid",
    "email",
    "profile"
  ] : []

  callback_urls = var.oauth_callback_urls
  logout_urls   = var.oauth_logout_urls
}

# ------------------------------------------------------------
# 4. Administrator Group
# ------------------------------------------------------------

resource "aws_cognito_user_group" "admin" {
  name         = "CTI_Admin"
  user_pool_id = aws_cognito_user_pool.this.id

  description = "Authorized CTI administrators"

  precedence = 1
}
