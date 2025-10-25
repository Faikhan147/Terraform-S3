terraform {
  backend "s3" {
    bucket         = "terraform-backend-all-envss"
    key            = "s3/terraform.tfstate"
    region         = "ap-southeast-2"
    encrypt        = true
  }
}
