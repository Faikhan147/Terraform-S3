# backend-qa.hcl
bucket         = "terraform-backend-all-env"
key            = "qa/terraform.tfstate"
region         = "ap-south-1"
dynamodb_table = "terraform-locks-qa"
encrypt        = true
