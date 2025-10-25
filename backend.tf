terraform {
  backend "s3" {
    bucket         = "terraform-backend-all-envs"
    key            = "s3/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
  }
}
