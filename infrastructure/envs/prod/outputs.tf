output "dev_delegation_fqdn" {
  description = "Delegated dev subdomain."
  value       = module.dev_delegation.fqdn
}

output "ses_configuration_set" {
  value = module.ses.configuration_set_name
}

output "ses_send_policy_arn" {
  value = module.ses.send_policy_arn
}

output "ses_amplify_compute_role_arn" {
  description = "Set as the compute role on the Amplify app (console)."
  value       = module.ses.amplify_compute_role_arn
}

output "ses_app_environment_variables" {
  value = module.ses.app_environment_variables
}