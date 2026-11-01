# Permanent backend. State was migrated here from local after bootstrap.
terraform {
  backend "s3" {
    bucket       = "canadatechintelligence-tfstate-285034436054"
    key          = "bootstrap/backend/terraform.tfstate"
    region       = "ca-central-1"
    encrypt      = true
    use_lockfile = true
  }
}