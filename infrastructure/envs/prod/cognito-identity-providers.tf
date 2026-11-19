
# ============================================================
# Canada Tech Intelligence
# PROD - Amazon Cognito External Identity Providers
# ============================================================

# ------------------------------------------------------------
# Identity Provider Management
# ------------------------------------------------------------
#
# All external identity providers are managed through:
#
# infrastructure/modules/cognito/main.tf
#
# Production environment configuration:
#
# infrastructure/envs/prod/cognito.tf
#
# Do not create duplicate identity provider resources here.
#
# Production AWS resources must be configured and validated
# independently from DEV.
# ------------------------------------------------------------


# ------------------------------------------------------------
# 1. Google OAuth
# ------------------------------------------------------------
#
# Managed by the shared Cognito module:
#
# module.cognito.aws_cognito_identity_provider.google
#
# Controlled through:
#
# enable_google_login
# google_client_id
# google_client_secret
#
# IMPORTANT:
# Preserve the existing production Google configuration.
# Do not enable or disable Google as part of LinkedIn rollout.
#
# Google credentials must be stored in production GitHub
# environment secrets when Google is enabled.
# ------------------------------------------------------------


# ------------------------------------------------------------
# 2. LinkedIn OpenID Connect
# ------------------------------------------------------------
#
# Managed by the shared Cognito module:
#
# module.cognito.aws_cognito_identity_provider.linkedin
#
# Provider name: LinkedIn
# Provider type: OIDC
#
# Issuer:
# https://www.linkedin.com/oauth
#
# OAuth scopes:
# openid profile email
#
# Production LinkedIn application:
# CTI - Production
#
# Production Cognito redirect URL:
#
# https://cti-prod-auth.auth.ca-central-1.amazoncognito.com/oauth2/idpresponse
#
# Verify this domain against the deployed production
# Cognito user pool before enabling authentication.
#
# Controlled through:
#
# enable_linkedin_login
# linkedin_client_id
# linkedin_client_secret
#
# Production GitHub environment secrets:
#
# PROD_LINKEDIN_CLIENT_ID
# PROD_LINKEDIN_CLIENT_SECRET
#
# Do not store LinkedIn credentials in Terraform source,
# terraform.tfvars, or GitHub workflow files.
#
# Do not reuse DEV LinkedIn credentials.
#
# Enable LinkedIn only after confirming the LinkedIn
# Sign In with LinkedIn using OpenID Connect product
# is active for the production application.
# ------------------------------------------------------------


# ------------------------------------------------------------
# 3. Microsoft Entra ID
# ------------------------------------------------------------
#
# Future implementation in the shared Cognito module.
# Not enabled for production.
# ------------------------------------------------------------


# ------------------------------------------------------------
# 4. Production Deployment Safety
# ------------------------------------------------------------
#
# Before production Terraform apply:
#
# 1. Verify production AWS account and user pool.
# 2. Verify existing authentication methods.
# 3. Verify production LinkedIn credentials.
# 4. Verify callback and logout URLs.
# 5. Run terraform fmt, validate, and plan.
# 6. Confirm there are no resource replacements/deletions.
# 7. Confirm Google and existing user pool are unchanged.
# 8. Review and explicitly approve the production apply.
#
# This file is documentation only.
# LinkedIn is NOT enabled by editing this file.
# ------------------------------------------------------------

