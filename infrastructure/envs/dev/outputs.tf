output "dev_zone_id" {
  description = "Hosted zone ID of dev.canadatechintelligence.ca."
  value       = module.dev_zone.zone_id
}

output "dev_zone_name_servers" {
  description = "Add these as an NS record named 'dev' in the prod canadatechintelligence.ca zone."
  value       = module.dev_zone.name_servers
}