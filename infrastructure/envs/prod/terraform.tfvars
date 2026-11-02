# --- General (provider) --------------------------------------------------------
aws_region = "ca-central-1"

# --- DNS: existing prod zone + dev delegation (modules/route53-delegation) -----
domain = "canadatechintelligence.ca"

dev_zone_name_servers = [
  "ns-1665.awsdns-16.co.uk",
  "ns-497.awsdns-62.com",
  "ns-879.awsdns-45.net",
  "ns-1352.awsdns-41.org",
]

# --- SES: email sending (modules/ses) ------------------------------------------
ses_from_address                = "contact@canadatechintelligence.ca" # only address prod may send from
ses_app_inbox                   = "contact@canadatechintelligence.ca" # where the app delivers mail
ses_alert_email                 = "contact@canadatechintelligence.ca" # bounce/complaint alarms
ses_create_dmarc_record         = true                                # no _dmarc record existed (verified)
ses_create_amplify_compute_role = true                                # attach to Amplify app in console