output "dev_zone_id" {
  description = "Hosted zone ID of dev.canadatechintelligence.ca."
  value       = module.dev_zone.zone_id
}

output "dev_zone_name_servers" {
  description = "Name servers delegated from the prod zone."
  value       = module.dev_zone.name_servers
}

output "ses_configuration_set" {
  value = module.ses.configuration_set_name
}

output "ses_send_policy_arn" {
  value = module.ses.send_policy_arn
}

output "ses_app_environment_variables" {
  value = module.ses.app_environment_variables
}