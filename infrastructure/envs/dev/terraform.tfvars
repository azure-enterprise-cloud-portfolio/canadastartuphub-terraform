# --- General (provider + tags) -------------------------------------------------
aws_region  = "ca-central-1"
project     = "canadatechintelligence-platform"
environment = "dev"

# --- DNS: dev hosted zone (modules/route53-zone) -------------------------------
dev_domain = "dev.canadatechintelligence.ca"

# --- SES: email sending (modules/ses) ------------------------------------------
ses_from_address                = "contact@dev.canadatechintelligence.ca" # only address dev may send from
ses_app_inbox                   = "contact@canadatechintelligence.ca"     # where the app delivers mail
ses_alert_email                 = null                                    # no alarm emails from dev
ses_create_amplify_compute_role = true                                    # role for the dev Amplify app (console)

# --- SES sandbox: verified recipients (ses.tf) ---------------------------------
ses_test_recipients = ["contact@canadatechintelligence.ca"]