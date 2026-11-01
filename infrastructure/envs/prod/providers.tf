provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "canadastartupdirectory"
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}
