# Stored in the central state bucket (prod account).
terraform {
  backend "s3" {
    bucket       = "canadatechintelligence-tfstate-285034436054"
    key          = "bootstrap/github-oidc/terraform.tfstate"
    region       = "ca-central-1"
    encrypt      = true
    use_lockfile = true
  }
}