output "route53_nameservers" {
  description = "Paste these into GoDaddy as custom nameservers."
  value       = module.amplify_domain.name_servers
}

output "hosted_zone_id" {
  value = module.amplify_domain.hosted_zone_id
}

output "amplify_verification_record" {
  value = module.amplify_domain.certificate_verification_dns_record
}

output "amplify_app_id" {
  value = module.amplify_app.app_id
}

output "amplify_default_domain" {
  description = "Test the deployment here before DNS cutover: https://main.<default_domain>"
  value       = module.amplify_app.default_domain
}
