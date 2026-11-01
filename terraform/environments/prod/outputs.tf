output "ses" {
  description = "SES identity, configuration set, send policy and the DNS records created."
  value = {
    identity_domain        = module.ses.identity_domain
    identity_arn           = module.ses.identity_arn
    dkim_status            = module.ses.dkim_status
    configuration_set_name = module.ses.configuration_set_name
    mail_from_domain       = module.ses.mail_from_domain
    sender_address         = module.ses.sender_address
    send_policy_arn        = module.ses.send_policy_arn
    dns_records_created    = module.ses.dns_records_created
  }
}
