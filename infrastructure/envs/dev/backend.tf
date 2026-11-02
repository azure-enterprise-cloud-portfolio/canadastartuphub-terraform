terraform {
  backend "s3" {
    bucket       = "cti-terraform-state-dev-ca-central-1" # <-- confirm your dev state bucket name
    key          = "envs/dev/terraform.tfstate"
    region       = "ca-central-1"
    encrypt      = true
    use_lockfile = true
  }
}