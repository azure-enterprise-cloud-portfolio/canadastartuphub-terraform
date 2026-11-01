
terraform {
  backend "s3" {
    bucket              = "cti-terraform-state-dev-ca-central-1"
    key                 = "bootstrap/oidc/dev/terraform.tfstate"
    region              = "ca-central-1"
    encrypt             = true
    use_lockfile        = true
    allowed_account_ids = ["959856141465"]
  }
}

