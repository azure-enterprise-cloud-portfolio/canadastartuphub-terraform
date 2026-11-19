
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
# 3. LinkedIn OpenID Connect
# ------------------------------------------------------------

# Managed by:
# module.cognito.aws_cognito_identity_provider.linkedin
#
# Provider type: OIDC
# Provider name: LinkedIn
#
# Enabled through:
# enable_linkedin_login = true
#
# Default: false (disabled)
#
# OpenID Connect scopes:
# openid profile email
#
# Configuration is passed from:
# infrastructure/envs/dev/cognito.tf
#
# LinkedIn Developer App authorized redirect:
# https://cti-dev-auth.auth.ca-central-1.amazoncognito.com/oauth2/idpresponse
#
# LinkedIn credentials must be supplied securely.
# Do not store Client Secrets in this file or Git.
#
# Production LinkedIn Sign-In remains disabled unless
# explicitly configured and approved.

