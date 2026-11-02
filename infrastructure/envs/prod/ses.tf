# SES for canadatechintelligence.ca (prod account 285034436054).
# The hosted zone was created in the console; Terraform only adds records to it.
data "aws_route53_zone" "primary" {
  name         = var.domain
  private_zone = false
}

module "ses" {
  source = "../../modules/ses"

  name_prefix  = "cti-prod"
  domain       = var.domain
  from_address = var.ses_from_address
  app_inbox    = var.ses_app_inbox
  alert_email  = var.ses_alert_email

  manage_dns          = true
  route53_zone_id     = data.aws_route53_zone.primary.zone_id
  create_dmarc_record = var.ses_create_dmarc_record

  create_amplify_compute_role = var.ses_create_amplify_compute_role
}