terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-lock-table"
  }
}

provider "aws" {
  region = var.region
}
