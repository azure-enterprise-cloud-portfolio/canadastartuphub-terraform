# PROD sends as contact@ on the apex domain and delivers to the existing
# Microsoft 365 mailbox. Adds only: 3 DKIM CNAMEs and the bounce.* MX + TXT.
# The apex MX, the apex SPF/verification TXT and every other existing record
# are left alone.
module "ses" {
  source = "../../modules/ses"

  environment         = "prod"
  hosted_zone_name    = var.hosted_zone_name
  identity_domain     = var.identity_domain
  mail_from_subdomain = var.mail_from_subdomain
  sender_address      = var.sender_address
  allowed_recipients  = var.allowed_recipients
}
