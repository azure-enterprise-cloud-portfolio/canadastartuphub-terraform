# Each role gets two inline policies:
#   1. terraform-state: plan roles read their own account's prefix;
#      deploy roles read/write it.
#   2. services: deploy roles manage the listed services in their own account;
#      plan roles get a read-only view of the same services.

################################################################################
# PROD account: prod/*
################################################################################

data "aws_iam_policy_document" "prod_state" {
  for_each = local.prod_roles

  statement {
    actions   = ["s3:ListBucket"]
    resources = [local.bucket_arn]
  }

  statement {
    actions   = each.value.actions
    resources = ["${local.bucket_arn}/prod/*"]
  }
}

resource "aws_iam_role_policy" "prod_state" {
  for_each = local.prod_roles

  name   = "terraform-state"
  role   = aws_iam_role.prod[each.key].id
  policy = data.aws_iam_policy_document.prod_state[each.key].json
}

################################################################################
# DEV account: dev/* (in the prod account's bucket)
################################################################################

data "aws_iam_policy_document" "dev_state" {
  for_each = local.dev_roles

  statement {
    actions   = ["s3:ListBucket"]
    resources = [local.bucket_arn]
  }

  statement {
    actions   = each.value.actions
    resources = ["${local.bucket_arn}/dev/*"]
  }
}

resource "aws_iam_role_policy" "dev_state" {
  provider = aws.dev
  for_each = local.dev_roles

  name   = "terraform-state"
  role   = aws_iam_role.dev[each.key].id
  policy = data.aws_iam_policy_document.dev_state[each.key].json
}

################################################################################
# Service permissions: what each role may create
################################################################################

locals {
  deploy_actions = [
    "apigateway:*",
    "dynamodb:*",
    "events:*",
    "lambda:*",
    "logs:*",
    "sns:*",
    "sqs:*",
    "ses:*",
  ]

  plan_read_actions = [
    "apigateway:GET",
    "dynamodb:Describe*",
    "dynamodb:List*",
    "events:Describe*",
    "events:List*",
    "lambda:Get*",
    "lambda:List*",
    "logs:Describe*",
    "logs:List*",
    "ses:Get*",
    "ses:List*",
    "sns:GetSubscriptionAttributes",
    "sns:GetTopicAttributes",
    "sns:List*",
    "sqs:GetQueueAttributes",
    "sqs:GetQueueUrl",
    "sqs:List*",
  ]
}

data "aws_iam_policy_document" "services" {
  for_each = toset(["plan", "deploy"])

  statement {
    sid       = "Services"
    actions   = each.key == "plan" ? local.plan_read_actions : local.deploy_actions
    resources = ["*"]
  }

  # Deploy roles configure SES but never send mail.
  dynamic "statement" {
    for_each = each.key == "deploy" ? [1] : []
    content {
      sid       = "DenySesSending"
      effect    = "Deny"
      actions   = ["ses:Send*"]
      resources = ["*"]
    }
  }
}

resource "aws_iam_role_policy" "prod_services" {
  for_each = local.prod_roles

  name   = "services"
  role   = aws_iam_role.prod[each.key].id
  policy = data.aws_iam_policy_document.services[each.key == "plan" ? "plan" : "deploy"].json
}

resource "aws_iam_role_policy" "dev_services" {
  provider = aws.dev
  for_each = local.dev_roles

  name   = "services"
  role   = aws_iam_role.dev[each.key].id
  policy = data.aws_iam_policy_document.services[each.key == "plan" ? "plan" : "deploy"].json
}