data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  configuration_set_name = "${var.name_prefix}-${var.environment}"
  mail_from_domain       = "${var.mail_from_subdomain}.${var.identity_domain}"
  sender_domain          = split("@", var.sender_address)[1]

  identity_arn          = "arn:${data.aws_partition.current.partition}:ses:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:identity/${var.identity_domain}"
  configuration_set_arn = "arn:${data.aws_partition.current.partition}:ses:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:configuration-set/${local.configuration_set_name}"
}

# Every message sent through this identity uses this configuration set unless
# the caller names another one.
resource "aws_sesv2_configuration_set" "this" {
  configuration_set_name = local.configuration_set_name

  delivery_options {
    tls_policy = "REQUIRE"
  }

  reputation_options {
    reputation_metrics_enabled = true
  }

  sending_options {
    sending_enabled = true
  }

  suppression_options {
    suppressed_reasons = ["BOUNCE", "COMPLAINT"]
  }
}

# Domain identity verified by Easy DKIM. With SES v2 the three DKIM CNAMEs
# verify the domain, so no _amazonses TXT record is needed — and nothing is
# added to the apex TXT record set, which holds the existing SPF and Microsoft
# verification values.
resource "aws_sesv2_email_identity" "this" {
  email_identity         = var.identity_domain
  configuration_set_name = aws_sesv2_configuration_set.this.configuration_set_name

  dkim_signing_attributes {
    next_signing_key_length = var.dkim_key_length
  }

  lifecycle {
    precondition {
      condition     = var.identity_domain == var.hosted_zone_name || endswith(var.identity_domain, ".${var.hosted_zone_name}")
      error_message = "identity_domain must be the hosted zone apex or a subdomain of it."
    }
    precondition {
      condition     = local.sender_domain == var.identity_domain
      error_message = "sender_address must belong to identity_domain."
    }
  }
}

# Custom MAIL FROM keeps SPF for SES mail on its own subdomain, so the apex SPF
# record (currently include:secureserver.net) is never touched.
resource "aws_sesv2_email_identity_mail_from_attributes" "this" {
  email_identity         = aws_sesv2_email_identity.this.email_identity
  mail_from_domain       = local.mail_from_domain
  behavior_on_mx_failure = "USE_DEFAULT_VALUE"

  depends_on = [
    aws_route53_record.mail_from_mx,
    aws_route53_record.mail_from_spf,
  ]
}

# The hosted zone already exists and is not managed here. It is read through a
# data source only: no aws_route53_zone resource, no import.
data "aws_route53_zone" "this" {
  name         = var.hosted_zone_name
  private_zone = false
}

# SES-specific records ONLY, each at a name that holds no existing record.
# allow_overwrite = false makes Terraform fail rather than take over a record
# that already exists at the same name and type. Independently, the deploy
# roles may change records only in this hosted zone, and their permissions
# boundary (terraform/bootstrap/github-oidc/policies.tf) refuses any change to
# the apex and the Microsoft 365 names (autodiscover, DKIM selectors, _dmarc).

# Three Easy DKIM CNAMEs: <token>._domainkey.<identity_domain>. The token names
# are new and cannot collide with other DKIM selectors (e.g. Microsoft 365's
# selector1/selector2).
resource "aws_route53_record" "dkim" {
  count = 3

  zone_id         = data.aws_route53_zone.this.zone_id
  name            = "${aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens[count.index]}._domainkey.${var.identity_domain}"
  type            = "CNAME"
  ttl             = var.record_ttl
  records         = ["${aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens[count.index]}.dkim.amazonses.com"]
  allow_overwrite = false
}

# MAIL FROM MX: bounces and complaints return to SES. This is an MX on the
# MAIL FROM subdomain only; the apex MX (Microsoft 365) is untouched.
resource "aws_route53_record" "mail_from_mx" {
  zone_id         = data.aws_route53_zone.this.zone_id
  name            = local.mail_from_domain
  type            = "MX"
  ttl             = var.record_ttl
  records         = ["10 feedback-smtp.${data.aws_region.current.region}.amazonses.com"]
  allow_overwrite = false
}

# MAIL FROM SPF, on the MAIL FROM subdomain only.
resource "aws_route53_record" "mail_from_spf" {
  zone_id         = data.aws_route53_zone.this.zone_id
  name            = local.mail_from_domain
  type            = "TXT"
  ttl             = var.record_ttl
  records         = ["v=spf1 include:amazonses.com -all"]
  allow_overwrite = false
}

# Least-privilege send policy: this identity, this configuration set, this From
# address and (optionally) these recipients only. It is created unattached —
# nothing in the app sends mail today. Attach it to whichever role eventually
# sends (e.g. an Amplify compute role); never to an IAM user with access keys.
data "aws_iam_policy_document" "send" {
  statement {
    sid       = "SendFromSenderAddressOnly"
    effect    = "Allow"
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = [local.identity_arn, local.configuration_set_arn]

    condition {
      test     = "StringEquals"
      variable = "ses:FromAddress"
      values   = [var.sender_address]
    }

    dynamic "condition" {
      for_each = length(var.allowed_recipients) > 0 ? [1] : []
      content {
        test     = "ForAllValues:StringEquals"
        variable = "ses:Recipients"
        values   = var.allowed_recipients
      }
    }
  }
}

resource "aws_iam_policy" "send" {
  name        = "${var.name_prefix}-ses-send-${var.environment}"
  path        = "/${var.name_prefix}/ses/${var.environment}/"
  description = "Send as ${var.sender_address} through SES identity ${var.identity_domain} (${var.environment})."
  policy      = data.aws_iam_policy_document.send.json
}
