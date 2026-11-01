terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "canadastartuphub"
      Environment = "dev"
      ManagedBy   = "terraform"
      Repository  = "azure-enterprise-cloud-portfolio/canadastartuphub"
    }
  }
}
