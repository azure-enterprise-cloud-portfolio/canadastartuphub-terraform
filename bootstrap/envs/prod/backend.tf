terraform {
  backend "s3" {
    bucket       = "canadastartupdirectory-tfstate"
    key          = "bootstrap/prod/terraform.tfstate"
    region       = "ca-central-1"
    encrypt      = true
    use_lockfile = true
  }
}
