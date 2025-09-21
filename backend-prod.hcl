# backend-prod.hcl
bucket         = "terraform-backend-all-env"
key            = "prod/terraform.tfstate"
region         = "ap-south-1"
dynamodb_table = "terraform-locks-prod"
encrypt        = true
