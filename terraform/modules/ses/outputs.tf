output "identity_domain" {
  description = "The SES domain identity."
  value       = aws_sesv2_email_identity.this.email_identity
}

output "identity_arn" {
  description = "ARN of the SES domain identity."
  value       = aws_sesv2_email_identity.this.arn
}

output "dkim_status" {
  description = "Easy DKIM status (PENDING until the CNAMEs resolve, then SUCCESS)."
  value       = aws_sesv2_email_identity.this.dkim_signing_attributes[0].status
}

output "configuration_set_name" {
  description = "Default configuration set for the identity."
  value       = aws_sesv2_configuration_set.this.configuration_set_name
}

output "mail_from_domain" {
  description = "Custom MAIL FROM domain."
  value       = local.mail_from_domain
}

output "sender_address" {
  description = "The From address the send policy allows."
  value       = var.sender_address
}

output "send_policy_arn" {
  description = "Unattached least-privilege send policy."
  value       = aws_iam_policy.send.arn
}

output "dns_records_created" {
  description = "Every Route 53 record this module owns (SES-specific only)."
  value = concat(
    [for r in aws_route53_record.dkim : "${r.name} CNAME"],
    ["${aws_route53_record.mail_from_mx.name} MX", "${aws_route53_record.mail_from_spf.name} TXT"],
  )
}
