data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  mail_from     = "${var.mail_from_subdomain}.${var.domain}"
  feedback_host = "feedback-smtp.${data.aws_region.current.region}.amazonses.com"
  dkim_tokens   = aws_sesv2_email_identity.this.dkim_signing_attributes[0].tokens
  app_inbox     = coalesce(var.app_inbox, var.from_address)
}

# --- Configuration set ---------------------------------------------------------
resource "aws_sesv2_configuration_set" "this" {
  configuration_set_name = "${var.name_prefix}-default"

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

  tags = var.tags
}

# --- Domain identity: Easy DKIM (2048-bit) + custom MAIL FROM ------------------
resource "aws_sesv2_email_identity" "this" {
  email_identity         = var.domain
  configuration_set_name = aws_sesv2_configuration_set.this.configuration_set_name

  dkim_signing_attributes {
    next_signing_key_length = "RSA_2048_BIT"
  }

  tags = var.tags
}

resource "aws_sesv2_email_identity_mail_from_attributes" "this" {
  email_identity         = aws_sesv2_email_identity.this.email_identity
  mail_from_domain       = local.mail_from
  behavior_on_mx_failure = "USE_DEFAULT_VALUE"
}

# --- DNS (Route 53). Root MX / SPF are never touched. --------------------------
resource "aws_route53_record" "dkim" {
  count   = var.manage_dns ? 3 : 0
  zone_id = var.route53_zone_id
  name    = "${local.dkim_tokens[count.index]}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = 1800
  records = ["${local.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "mail_from_mx" {
  count   = var.manage_dns ? 1 : 0
  zone_id = var.route53_zone_id
  name    = local.mail_from
  type    = "MX"
  ttl     = 1800
  records = ["10 ${local.feedback_host}"]
}

resource "aws_route53_record" "mail_from_spf" {
  count   = var.manage_dns ? 1 : 0
  zone_id = var.route53_zone_id
  name    = local.mail_from
  type    = "TXT"
  ttl     = 1800
  records = ["v=spf1 include:amazonses.com ~all"]
}

resource "aws_route53_record" "dmarc" {
  count   = var.manage_dns && var.create_dmarc_record ? 1 : 0
  zone_id = var.route53_zone_id
  name    = "_dmarc.${var.domain}"
  type    = "TXT"
  ttl     = 1800
  records = ["v=DMARC1; p=none; rua=mailto:${local.app_inbox}; fo=1"]
}

# --- Reputation alarms (CloudWatch -> SNS) -------------------------------------
resource "aws_sns_topic" "alarms" {
  name = "${var.name_prefix}-ses-alarms"
  tags = var.tags
}

resource "aws_sns_topic_policy" "alarms" {
  arn = aws_sns_topic.alarms.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowCloudWatchAlarms"
      Effect    = "Allow"
      Principal = { Service = "cloudwatch.amazonaws.com" }
      Action    = "sns:Publish"
      Resource  = aws_sns_topic.alarms.arn
      Condition = {
        StringEquals = { "AWS:SourceAccount" = data.aws_caller_identity.current.account_id }
      }
    }]
  })
}

resource "aws_sns_topic_subscription" "alert_email" {
  count     = var.alert_email == null ? 0 : 1
  topic_arn = aws_sns_topic.alarms.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "bounce_rate" {
  alarm_name          = "${var.name_prefix}-ses-bounce-rate"
  alarm_description   = "SES bounce rate at or above ${var.bounce_rate_threshold * 100}% (AWS reviews at ~5%)."
  namespace           = "AWS/SES"
  metric_name         = "Reputation.BounceRate"
  statistic           = "Maximum"
  period              = 3600
  evaluation_periods  = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.bounce_rate_threshold
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "complaint_rate" {
  alarm_name          = "${var.name_prefix}-ses-complaint-rate"
  alarm_description   = "SES complaint rate at or above ${var.complaint_rate_threshold * 100}% (AWS reviews at ~0.1%)."
  namespace           = "AWS/SES"
  metric_name         = "Reputation.ComplaintRate"
  statistic           = "Maximum"
  period              = 3600
  evaluation_periods  = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = var.complaint_rate_threshold
  treat_missing_data  = "notBreaching"
  alarm_actions       = [aws_sns_topic.alarms.arn]
  ok_actions          = [aws_sns_topic.alarms.arn]
  tags                = var.tags
}

# --- Send policy ----------------------------------------------------------------
# Locked to from_address (bare or with a display name) and this configuration set.
# Resources include every identity in the account because, in the SES sandbox,
# IAM also checks ses:SendEmail against the verified *recipient* identity.
data "aws_iam_policy_document" "send" {
  statement {
    sid     = "SendAsFromAddressOnly"
    effect  = "Allow"
    actions = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = [
      "arn:aws:ses:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:identity/*",
      aws_sesv2_configuration_set.this.arn,
    ]

    condition {
      test     = "StringLike"
      variable = "ses:FromAddress"
      values = [
        var.from_address,
        "*<${var.from_address}>",
      ]
    }
  }
}

resource "aws_iam_policy" "send" {
  name        = "${var.name_prefix}-ses-send"
  description = "Send email via SES as ${var.from_address} only"
  policy      = data.aws_iam_policy_document.send.json
  tags        = var.tags
}

# --- Application access --------------------------------------------------------
data "aws_iam_policy_document" "amplify_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "amplify_compute" {
  count              = var.create_amplify_compute_role ? 1 : 0
  name               = "${var.name_prefix}-amplify-compute"
  assume_role_policy = data.aws_iam_policy_document.amplify_trust.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "amplify_compute" {
  count      = var.create_amplify_compute_role ? 1 : 0
  role       = aws_iam_role.amplify_compute[0].name
  policy_arn = aws_iam_policy.send.arn
}

resource "aws_iam_role_policy_attachment" "existing" {
  for_each   = toset(var.attach_to_role_names)
  role       = each.value
  policy_arn = aws_iam_policy.send.arn
}