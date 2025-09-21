terraform {
  backend "s3" {
    bucket         = "terraform-backend-all-env"
    key            = "s3/terraform.tfstate"
    region         = "ap-south-1"
    kms_key_id     = "arn:aws:kms:ap-south-1:923884399206:alias/aws/s3"
    encrypt        = true
  }
}
