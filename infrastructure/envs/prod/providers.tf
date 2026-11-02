provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "canadatechintelligence-platform"
      Environment = "prod"
      ManagedBy   = "terraform"
      Repo        = "canadastartuphub-terraform"
    }
  }
}
