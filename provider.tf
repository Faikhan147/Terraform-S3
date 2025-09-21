terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14.0"
    }
  }
  # Backend configured via backend-prod.hcl
}

provider "aws" {
  region = var.region
}
