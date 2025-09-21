  backend "s3" {
    bucket         = "my-private-bucket-ap-south-1"
    key            = "prod/terraform.tfstate"
    region         = "ap-south-1"
    kms_key_id     = "arn:aws:kms:ap-south-1:923884399206:alias/aws/s3"
    encrypt        = true
  }
}
