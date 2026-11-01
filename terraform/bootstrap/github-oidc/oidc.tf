# GitHub OIDC provider for the dev account. Created only if the dev account
# doesn't have one yet. The prod account's provider already exists (data.tf).
resource "aws_iam_openid_connect_provider" "dev" {
  provider = aws.dev
  count    = var.create_dev_oidc_provider ? 1 : 0

  url            = local.oidc_url
  client_id_list = ["sts.amazonaws.com"]
}