output "hosted_zone_id" {
  value = local.zone_id
}

output "name_servers" {
  description = "Set these as custom nameservers at GoDaddy."
  value       = var.create_hosted_zone ? aws_route53_zone.this[0].name_servers : null
}

output "certificate_verification_dns_record" {
  value = aws_amplify_domain_association.this.certificate_verification_dns_record
}
