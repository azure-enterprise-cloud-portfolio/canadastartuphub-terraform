output "zone_id" {
  description = "Hosted zone ID."
  value       = aws_route53_zone.this.zone_id
}

output "zone_arn" {
  value = aws_route53_zone.this.arn
}

output "zone_name" {
  value = aws_route53_zone.this.name
}

output "name_servers" {
  description = "Use these for the NS delegation record in the parent zone."
  value       = aws_route53_zone.this.name_servers
}