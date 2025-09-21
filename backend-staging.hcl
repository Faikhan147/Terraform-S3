bucket         = "terraform-backend-all-env"
region         = "ap-south-1"
key            = "staging/terraform.tfstate"
dynamodb_table = "terraform-locks-staging"
kms_key_id     = "arn:aws:kms:ap-south-1:923884399206:alias/aws/s3"
encrypt        = true
