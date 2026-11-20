
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

# --- LinkedIn OIDC — Production ----------------------------

enable_linkedin_login = true

# --- Microsoft Entra ID OIDC — Production -------------------
#
# Microsoft app registration: CTI - Production
#
# Credentials are supplied through GitHub PROD environment
# secrets. Do not store Client Secrets in terraform.tfvars.
#
# Keep disabled until Microsoft DEV login is tested and
# production deployment is approved.
# ------------------------------------------------------------

enable_microsoft_login = false

# Directory (tenant) ID from Microsoft Entra ID.
# Replace with the actual tenant GUID before enabling login.
microsoft_tenant_id = "e1349025-9afa-4554-81d6-a475c0253199"

# GitHub PROD environment secrets:
#
# PROD_MICROSOFT_CLIENT_ID
# PROD_MICROSOFT_CLIENT_SECRET
