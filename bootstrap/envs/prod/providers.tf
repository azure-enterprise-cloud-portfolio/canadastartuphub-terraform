provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "canadastartuphub"
      Environment = "prod"
      ManagedBy   = "terraform"
    }
  }
}
