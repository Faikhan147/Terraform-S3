terraform {
  backend "s3" {
    bucket         = "terraform-backend-all-envs"
    key            = "s3/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
