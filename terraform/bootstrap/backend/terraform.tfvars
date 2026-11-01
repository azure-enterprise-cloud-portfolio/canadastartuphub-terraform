state_bucket_name = "canadatechintelligence-tfstate-285034436054"
aws_account_id    = "285034436054"

admin_principal_arns = [
  "arn:aws:iam::285034436054:role/aws-reserved/sso.amazonaws.com/*AWSReservedSSO_AWSAdministratorAccess_*"
]

dev_state_principal_arns = [
  "arn:aws:iam::959856141465:role/canadastartuphub-terraform-dev",
  "arn:aws:iam::959856141465:role/canadastartuphub-terraform-plan",
]