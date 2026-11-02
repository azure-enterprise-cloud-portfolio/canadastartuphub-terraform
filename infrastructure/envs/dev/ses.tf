# SES for dev.canadatechintelligence.ca (dev account 959856141465).
# Dev stays in the SES sandbox: it can only send to verified recipients.
module "ses" {
  source = "../../modules/ses"

  name_prefix  = "cti-${var.environment}"
  domain       = var.dev_domain
  from_address = var.ses_from_address
  app_inbox    = var.ses_app_inbox
  alert_email  = var.ses_alert_email

  manage_dns          = true
  route53_zone_id     = module.dev_zone.zone_id
  create_dmarc_record = false # parent domain's _dmarc policy covers subdomains

  create_amplify_compute_role = var.ses_create_amplify_compute_role
}

# Sandbox recipients: each address gets a one-time verification email.
resource "aws_sesv2_email_identity" "test_recipient" {
  for_each       = toset(var.ses_test_recipients)
  email_identity = each.value
}