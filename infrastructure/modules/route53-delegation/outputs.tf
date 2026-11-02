output "fqdn" {
  description = "Delegated subdomain."
  value       = aws_route53_record.delegation.fqdn
}

output "parent_zone_id" {
  value = data.aws_route53_zone.parent.zone_id
}