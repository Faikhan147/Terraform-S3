# S3 backend bucket
resource "aws_s3_bucket" "terraform_backend" {
  bucket = "terraform-backend-all-env"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "Terraform Backend Bucket"
  }
}

# DynamoDB lock tables
locals {
  tables = ["prod", "staging", "qa"]
}

resource "aws_dynamodb_table" "terraform_lock" {
  for_each      = toset(local.tables)
  name          = "terraform-locks-${each.key}"
  billing_mode  = "PAY_PER_REQUEST"
  hash_key      = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Lock Table"
  }
}
