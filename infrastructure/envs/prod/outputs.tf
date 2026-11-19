
# ============================================================
# Canada Tech Intelligence
# Production Environment - Terraform Outputs
# ============================================================

# ------------------------------------------------------------
# 1. Route 53 - Production DNS
# ------------------------------------------------------------

output "dev_delegation_fqdn" {
  description = "Delegated dev subdomain."
  value       = module.dev_delegation.fqdn
}

# ------------------------------------------------------------
# 2. Amazon SES
# ------------------------------------------------------------

output "ses_configuration_set" {
  value = module.ses.configuration_set_name
}

output "ses_send_policy_arn" {
  value = module.ses.send_policy_arn
}

output "ses_amplify_compute_role_arn" {
  description = "Set as the compute role on the prod Amplify app (console)."
  value       = module.ses.amplify_compute_role_arn
}

output "ses_app_environment_variables" {
  value = module.ses.app_environment_variables
}

# ------------------------------------------------------------
# 3. Amazon Cognito - Authentication
# Same output names as DEV
# ------------------------------------------------------------

output "cognito_user_pool_id" {
  description = "CTI Cognito User Pool ID"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "CTI Cognito web application client ID"
  value       = module.cognito.user_pool_client_id
}

output "cognito_user_pool_arn" {
  description = "CTI Cognito User Pool ARN"
  value       = module.cognito.user_pool_arn
}

output "cognito_admin_group_name" {
  description = "CTI Cognito administrator group"
  value       = module.cognito.admin_group_name
}
