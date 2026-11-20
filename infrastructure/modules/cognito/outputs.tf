
# ============================================================
# Canada Tech Intelligence
# Amazon Cognito Module - Terraform Outputs
# ============================================================

# ------------------------------------------------------------
# 1. Cognito User Pool
# ------------------------------------------------------------

output "user_pool_id" {
  description = "CTI Cognito User Pool ID"
  value       = aws_cognito_user_pool.this.id
}

output "user_pool_client_id" {
  description = "CTI web application client ID"
  value       = aws_cognito_user_pool_client.web.id
}

output "user_pool_arn" {
  description = "CTI Cognito User Pool ARN"
  value       = aws_cognito_user_pool.this.arn
}

# ------------------------------------------------------------
# 2. Administrator Group
# ------------------------------------------------------------

output "admin_group_name" {
  description = "Cognito administrator group"
  value       = aws_cognito_user_group.admin.name
}

# ------------------------------------------------------------
# 3. Federated Authentication Status
# ------------------------------------------------------------

output "google_login_enabled" {
  description = "Whether Google OAuth login is enabled"
  value       = var.enable_google_login
}

output "linkedin_login_enabled" {
  description = "Whether LinkedIn OIDC login is enabled"
  value       = var.enable_linkedin_login
}

output "microsoft_login_enabled" {
  description = "Whether Microsoft Entra ID OIDC login is enabled"
  value       = var.enable_microsoft_login
}

output "federated_login_enabled" {
  description = "Whether Cognito federated authentication is enabled"
  value       = local.enable_federated_login
}

# ------------------------------------------------------------
# 4. Cognito Hosted Domain
# ------------------------------------------------------------

output "cognito_domain" {
  description = "Cognito hosted domain for OAuth authentication"
  value = local.enable_federated_login ? (
    "https://${aws_cognito_user_pool_domain.this[0].domain}.auth.ca-central-1.amazoncognito.com"
  ) : null
}


