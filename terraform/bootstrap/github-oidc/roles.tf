# The CI roles and who may assume them. Each account gets a read-only plan
# role and a deploy role, trusted only from this GitHub repository.

################################################################################
# PROD account
################################################################################

data "aws_iam_policy_document" "prod_trust" {
  for_each = local.prod_roles

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.prod.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = each.value.subjects
    }
  }
}

resource "aws_iam_role" "prod" {
  for_each = local.prod_roles

  name                 = "${var.name_prefix}-terraform-${each.key}"
  assume_role_policy   = data.aws_iam_policy_document.prod_trust[each.key].json
  max_session_duration = 3600
}

################################################################################
# DEV account
################################################################################

data "aws_iam_policy_document" "dev_trust" {
  for_each = local.dev_roles

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.dev_oidc_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = each.value.subjects
    }
  }
}

resource "aws_iam_role" "dev" {
  provider = aws.dev
  for_each = local.dev_roles

  name                 = "${var.name_prefix}-terraform-${each.key}"
  assume_role_policy   = data.aws_iam_policy_document.dev_trust[each.key].json
  max_session_duration = 3600
}
