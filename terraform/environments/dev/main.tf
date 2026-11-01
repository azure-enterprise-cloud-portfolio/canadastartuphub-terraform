# DEV verifies dev.canadatechintelligence.ca and may send only to the real
# contact mailbox. Adds only: 3 DKIM CNAMEs under dev.* and the bounce.dev.*
# MX + TXT. No existing record is touched.
module "ses" {
  source = "../../modules/ses"

  environment         = "dev"
  hosted_zone_name    = var.hosted_zone_name
  identity_domain     = var.identity_domain
  mail_from_subdomain = var.mail_from_subdomain
  sender_address      = var.sender_address
  allowed_recipients  = var.allowed_recipients
}
