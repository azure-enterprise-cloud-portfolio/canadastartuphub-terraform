terraform {
  backend "s3" {
    bucket       = "canadastartuphub-tfstate"
    key          = "envs/prod/terraform.tfstate"
    region       = "ca-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
