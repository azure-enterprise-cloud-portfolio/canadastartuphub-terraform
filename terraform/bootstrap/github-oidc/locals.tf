locals {
  oidc_url   = "https://token.actions.githubusercontent.com"
  oidc_host  = "token.actions.githubusercontent.com"
  bucket_arn = "arn:aws:s3:::${var.state_bucket_name}"
  repo       = "repo:${var.github_repository}"

  plan_subjects = ["${local.repo}:pull_request", "${local.repo}:ref:refs/heads/main"]
  read_only     = ["s3:GetObject"]
  read_write    = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]

  prod_roles = {
    plan = { subjects = local.plan_subjects, actions = local.read_only }
    prod = { subjects = ["${local.repo}:environment:production"], actions = local.read_write }
  }

  dev_roles = {
    plan = { subjects = local.plan_subjects, actions = local.read_only }
    dev  = { subjects = ["${local.repo}:environment:dev"], actions = local.read_write }
  }

  dev_oidc_arn = (
    var.create_dev_oidc_provider
    ? aws_iam_openid_connect_provider.dev[0].arn
    : data.aws_iam_openid_connect_provider.dev[0].arn
  )
}