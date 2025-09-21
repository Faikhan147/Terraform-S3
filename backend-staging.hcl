# backend-staging.hcl
bucket         = "terraform-backend-all-env"
key            = "staging/terraform.tfstate"
region         = "ap-south-1"
dynamodb_table = "terraform-locks-staging"
encrypt        = true
