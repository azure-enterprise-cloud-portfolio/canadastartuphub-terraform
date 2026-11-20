
# ============================================================
# Canada Tech Intelligence
# DEV - Amazon Cognito External Identity Providers
# ============================================================
#
# Environment: DEV
#
# All identity providers are managed centrally in:
#
# infrastructure/modules/cognito/main.tf
#
# Provider configuration is supplied through:
#
# infrastructure/envs/dev/cognito.tf
#
# Do not create duplicate identity provider resources here.
# ============================================================


# ------------------------------------------------------------
# 1. Google OAuth
# ------------------------------------------------------------
#
# Managed resource:
# module.cognito.aws_cognito_identity_provider.google[0]
#
# Provider type: Google
# Provider name: Google
#
# Enabled through:
# enable_google_login = true
#
# OAuth scopes:
# openid email profile
#
# Google credentials must be supplied securely.
#
# Existing Google authentication must remain unchanged.


# ------------------------------------------------------------
# 2. LinkedIn OpenID Connect
# ------------------------------------------------------------
#
# Managed resource:
# module.cognito.aws_cognito_identity_provider.linkedin[0]
#
# Provider type: OIDC
# Provider name: LinkedIn
#
# Enabled through:
# enable_linkedin_login = true
#
# OAuth scopes:
# openid profile email
#
# LinkedIn DEV authorized redirect URI:
#
# https://cti-dev-auth.auth.ca-central-1.amazoncognito.com/oauth2/idpresponse
#
# Credentials must be supplied securely.
#
# Existing LinkedIn authentication must remain unchanged.


# ------------------------------------------------------------
# 3. Microsoft Entra ID OpenID Connect
# ------------------------------------------------------------
#
# Managed resource:
# module.cognito.aws_cognito_identity_provider.microsoft[0]
#
# Provider type: OIDC
# Provider name: Microsoft
#
# Enabled through:
# enable_microsoft_login = true
#
# Initial deployment:
# enable_microsoft_login = false
#
# OAuth scopes:
# openid profile email
#
# Tenant-specific OIDC issuer:
#
# https://login.microsoftonline.com/<tenant-id>/v2.0
#
# Microsoft DEV authorized redirect URI:
#
# https://cti-dev-auth.auth.ca-central-1.amazoncognito.com/oauth2/idpresponse
#
# Microsoft Entra application:
# CTI - Development
#
# Required configuration:
#
# microsoft_tenant_id
# microsoft_client_id
# microsoft_client_secret
#
# Client ID and Client Secret must be supplied securely
# through the DEV GitHub Actions environment.
#
# Do not hardcode secrets in Terraform configuration.
#
# Microsoft must be tested in DEV before PROD deployment.


# ------------------------------------------------------------
# 4. Native Cognito Authentication
# ------------------------------------------------------------
#
# Provider name: COGNITO
#
# Email/password authentication remains enabled.
#
# Existing functionality:
#
# - Customer registration
# - Email confirmation
# - Password reset
# - Session management
# - Protected /workspace
#
# Native Cognito authentication must not be removed.


# ------------------------------------------------------------
# 5. Security and Deployment Rules
# ------------------------------------------------------------
#
# 1. Preserve working Google and LinkedIn authentication.
#
# 2. Use separate Microsoft app registrations for DEV/PROD.
#
# 3. Do not place secrets in Git.
#
# 4. Do not create duplicate identity provider resources.
#
# 5. Do not automatically link accounts by email address.
#
# 6. Do not automatically mark Microsoft emails verified.
#
# 7. Review Terraform plan before enabling Microsoft.
#
# 8. Validate Microsoft login in DEV before PROD.
#
# 9. Manage Cognito users through AWS Console.
#
# 10. Keep production authentication unchanged during
#     initial Microsoft DEV integration.
# ============================================================


