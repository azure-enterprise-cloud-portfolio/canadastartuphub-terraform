terraform {
  backend "s3" {
    bucket       = "canadastartupdirectory-tfstate"
    key          = "envs/prod/terraform.tfstate"
    region       = "ca-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
