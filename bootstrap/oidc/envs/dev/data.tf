# --- Read-only role for PR plans (GitHub environment: pr-plan) -----------------
data "aws_iam_policy_document" "plan_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.github_oidc.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:environment:pr-plan"]
    }
  }
}

resource "aws_iam_role" "plan" {
  name               = "cti-github-oidc-dev-plan"
  description        = "GitHub Actions PR plan role (read-only)"
  assume_role_policy = data.aws_iam_policy_document.plan_trust.json

  tags = {
    Project     = "CanadaTechIntelligence"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_iam_role_policy_attachment" "plan_readonly" {
  role       = aws_iam_role.plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}