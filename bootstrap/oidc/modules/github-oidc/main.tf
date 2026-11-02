# GitHub Actions OIDC federation with AWS IAM.
# Uses short-lived credentials instead of AWS access keys.

data "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_oidc_provider ? 0 : 1
  url   = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.create_github_oidc_provider ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  tags = var.tags
}

locals {
  github_oidc_provider_arn = (
    var.create_github_oidc_provider
    ? aws_iam_openid_connect_provider.github[0].arn
    : data.aws_iam_openid_connect_provider.github[0].arn
  )

  # GitHub sends either the classic subject (repo:owner/repo:...) or, when
  # immutable subjects are enabled, repo:owner@ownerId/repo@repoId:...
  github_subjects = compact([
    "repo:${var.github_repository}:environment:${var.environment}",
    var.github_sub_claim_prefix == null ? "" : "${var.github_sub_claim_prefix}:environment:${var.environment}",
  ])
}

data "aws_iam_policy_document" "github_actions_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.github_oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = local.github_subjects
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = var.role_name
  description        = "GitHub Actions ${var.environment} Terraform role"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume.json

  tags = var.tags
}