output "configuration_set_name" {
  description = "Pass as ConfigurationSetName on every send (required by the IAM policy)."
  value       = aws_sesv2_configuration_set.this.configuration_set_name
}

output "identity_arn" {
  value = aws_sesv2_email_identity.this.arn
}

output "send_policy_arn" {
  value = aws_iam_policy.send.arn
}

output "amplify_compute_role_arn" {
  description = "Set as the compute role on the Amplify app."
  value       = try(aws_iam_role.amplify_compute[0].arn, null)
}

output "alarm_topic_arn" {
  value = aws_sns_topic.alarms.arn
}

output "app_environment_variables" {
  description = "Environment variables for the application (no AWS_ prefix; Amplify reserves it)."
  value = {
    SES_REGION            = data.aws_region.current.region
    SES_FROM_ADDRESS      = var.from_address
    SES_CONFIGURATION_SET = aws_sesv2_configuration_set.this.configuration_set_name
    CONTACT_INBOX         = local.app_inbox
  }
}

output "dns_records" {
  description = "Records to create manually when manage_dns = false."
  value = concat(
    [for t in local.dkim_tokens : { type = "CNAME", name = "${t}._domainkey.${var.domain}", value = "${t}.dkim.amazonses.com" }],
    [
      { type = "MX", name = local.mail_from, value = "10 ${local.feedback_host}" },
      { type = "TXT", name = local.mail_from, value = "v=spf1 include:amazonses.com ~all" },
    ]
  )
}