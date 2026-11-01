output "route53_nameservers" {
  description = "Paste these into GoDaddy as custom nameservers."
  value       = aws_route53_zone.this.name_servers
}

output "hosted_zone_id" {
  value = aws_route53_zone.this.zone_id
}
