# Bootstrap 2 of 2: GitHub Actions OIDC roles in the prod and dev accounts.
# Applied only by the account owner from a local CLI.

# Prod account: the GitHub OIDC provider already exists.
data "aws_iam_openid_connect_provider" "prod" {
  url = local.oidc_url
}

# Dev account: used only if the provider already exists there.
data "aws_iam_openid_connect_provider" "dev" {
  provider = aws.dev
  count    = var.create_dev_oidc_provider ? 0 : 1

  url = local.oidc_url
}