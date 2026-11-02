terraform {
  backend "s3" {
    bucket       = "cti-terraform-state-prod-ca-central-1"
    key          = "envs/prod/terraform.tfstate"
    region       = "ca-central-1"
    encrypt      = true
    use_lockfile = true
  }
}