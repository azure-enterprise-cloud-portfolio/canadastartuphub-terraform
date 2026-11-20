
# ============================================================
# Canada Tech Intelligence
# Development Environment - Terraform Variables
# ============================================================

# --- General (provider + tags) -------------------------------
aws_region  = "ca-central-1"
project     = "canadatechintelligence-platform"
environment = "dev"

# --- DNS: dev hosted zone (modules/route53-zone) --------------
dev_domain = "dev.canadatechintelligence.ca"

# --- SES: email sending (modules/ses) -------------------------
ses_from_address                = "contact@dev.canadatechintelligence.ca" # only address dev may send from
ses_app_inbox                   = "contact@canadatechintelligence.ca"     # where the app delivers mail
ses_alert_email                 = null                                    # no alarm emails from dev
ses_create_amplify_compute_role = true                                    # role for the dev Amplify app (console)

# --- SES sandbox: verified recipients (ses.tf) ----------------
ses_test_recipients = ["contact@canadatechintelligence.ca"]

# --- LinkedIn OIDC --------------------------------------------
enable_linkedin_login = true

# --- Microsoft Entra ID OIDC ----------------------------------
#
# CTI - Development Microsoft app registration
#
# Keep disabled until DEV credentials are configured in
# GitHub Actions and the Terraform plan is reviewed.
# --------------------------------------------------------------

enable_microsoft_login = false

# Replace with the actual Directory (tenant) ID from
# Microsoft Entra ID -> App registrations -> CTI - Development.
microsoft_tenant_id = "REPLACE_WITH_YOUR_TENANT_GUID"

# Microsoft Client ID and Client Secret are supplied securely
# through the GitHub DEV environment secrets:
#
# DEV_MICROSOFT_CLIENT_ID
# DEV_MICROSOFT_CLIENT_SECRET
#
# Do not store Microsoft Client Secrets in this file.

