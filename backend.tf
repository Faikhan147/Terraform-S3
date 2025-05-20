terraform {
  backend "s3" {
    bucket         = "terraform-backend-faisal-khan"
    key            = "s3/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
