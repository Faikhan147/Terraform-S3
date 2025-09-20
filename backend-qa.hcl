bucket         = "terraform-backend-all-env"
key            = "qa/terraform.tfstate"
region         = "ap-south-1"
encrypt        = true
dynamodb_table = "terraform-locks-qa"
