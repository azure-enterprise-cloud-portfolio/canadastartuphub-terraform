locals {
  environment = "prod"

  tags = {
    Project     = "CanadaTechIntelligence"
    Environment = local.environment
    ManagedBy   = "Terraform"
  }

  # Both subject formats: immutable (what GitHub sends now) and classic
  subject_prefixes = [
    var.github_sub_claim_prefix,
    "repo:${var.github_repository}",
  ]

  # Who may use the read-only plan role:
  #   PRs into main (terraform-pr.yml) and the plan job in terraform-prod.yml
  plan_subjects = ["environment:pr-plan", "ref:refs/heads/main"]
}

# --- Deploy role (GitHub environment: prod) ------------------------------------
module "github_oidc" {
  source = "../../modules/github-oidc"

  github_repository           = var.github_repository
  github_sub_claim_prefix     = var.github_sub_claim_prefix
  role_name                   = "cti-github-oidc-${local.environment}"
  environment                 = local.environment
  create_github_oidc_provider = var.create_github_oidc_provider

  tags = local.tags
}

# Development phase: full access for the deploy role. Tighten before launch.
resource "aws_iam_role_policy_attachment" "deploy_admin" {
  role       = module.github_oidc.github_actions_role_name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# --- Read-only plan role -------------------------------------------------------
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
      values = flatten([
        for p in local.subject_prefixes : [
          for s in local.plan_subjects : "${p}:${s}"
        ]
      ])
    }
  }
}

resource "aws_iam_role" "plan" {
  name               = "cti-github-oidc-${local.environment}-plan"
  description        = "GitHub Actions ${local.environment} plan role (read-only)"
  assume_role_policy = data.aws_iam_policy_document.plan_trust.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "plan_readonly" {
  role       = aws_iam_role.plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}
