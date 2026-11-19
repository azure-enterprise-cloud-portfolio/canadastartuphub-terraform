
# ============================================================
# Canada Tech Intelligence
# Amazon Cognito - External Identity Providers
# ============================================================

# Identity providers are managed in the shared Cognito module:
#
# infrastructure/modules/cognito/main.tf
#
# Do not create duplicate identity providers here.


# ------------------------------------------------------------
# 1. Google OAuth
# ------------------------------------------------------------

# Managed by:
# module.cognito.aws_cognito_identity_provider.google
#
# Enabled through:
# enable_google_login = true
#
# Configuration is passed from:
# infrastructure/envs/dev/cognito.tf


# ------------------------------------------------------------
# 2. Microsoft Entra ID (future)
# ------------------------------------------------------------

# Future implementation in the shared Cognito module.


# ------------------------------------------------------------
# 3. LinkedIn OpenID Connect (future)
# ------------------------------------------------------------

# Future implementation in the shared Cognito module.
