
# ============================================================
# Canada Tech Intelligence
# Development Environment - Terraform Outputs
# ============================================================

# ------------------------------------------------------------
# 1. Route 53 - Development DNS
# ------------------------------------------------------------

output "dev_zone_id" {
  description = "Hosted zone ID of dev.canadatechintelligence.ca."
  value       = module.dev_zone.zone_id
}

output "dev_zone_name_servers" {
  description = "Name servers delegated from the prod zone."
  value       = module.dev_zone.name_servers
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
  description = "Set as the compute role on the dev Amplify app (console)."
  value       = module.ses.amplify_compute_role_arn
}

output "ses_app_environment_variables" {
  value = module.ses.app_environment_variables
}

# ------------------------------------------------------------
# 3. Amazon Cognito - Authentication
# Same output names as PROD
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
