locals {
  is_custom_cert = var.certificate_type == "CUSTOM"
  zone_id        = var.create_hosted_zone ? aws_route53_zone.this[0].zone_id : var.hosted_zone_id
}

resource "aws_route53_zone" "this" {
  count = var.create_hosted_zone ? 1 : 0
  name  = var.domain_name
  tags  = var.tags
}

# ---- Custom ACM: only created when certificate_type = CUSTOM ----
resource "aws_acm_certificate" "this" {
  count                     = local.is_custom_cert ? 1 : 0
  provider                  = aws.us_east_1
  domain_name               = var.domain_name
  subject_alternative_names = ["www.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_route53_record" "acm_validation" {
  for_each = local.is_custom_cert ? {
    for dvo in aws_acm_certificate.this[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  zone_id         = local.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "this" {
  count                   = local.is_custom_cert ? 1 : 0
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for r in aws_route53_record.acm_validation : r.fqdn]
}

# ---- Amplify domain association ----
resource "aws_amplify_domain_association" "this" {
  app_id      = var.amplify_app_id
  domain_name = var.domain_name

  certificate_settings {
    type                   = var.certificate_type
    custom_certificate_arn = local.is_custom_cert ? aws_acm_certificate_validation.this[0].certificate_arn : null
  }

  dynamic "sub_domain" {
    for_each = var.subdomains
    content {
      branch_name = var.amplify_branch
      prefix      = sub_domain.value
    }
  }

  # Don't block apply on cert validation: with a fresh zone, validation can't
  # succeed until the registrar (GoDaddy) delegates to the Route 53 nameservers,
  # which only exist after this apply. Verification completes asynchronously.
  wait_for_verification = false

  # For AMPLIFY_MANAGED, Amplify writes validation records into this zone,
  # so it must exist first.
  depends_on = [aws_route53_zone.this]
}