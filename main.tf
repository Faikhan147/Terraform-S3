# s3.tf
resource "aws_s3_bucket" "terraform_backend" {
  bucket = "terraform-backend-all-env"
  force_destroy = true
  tags = {
    Environment = "Terraform"
  }
}

# Versioning separate
resource "aws_s3_bucket_versioning" "backend_versioning" {
  bucket = aws_s3_bucket.terraform_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# workspace files
locals {
  workspaces = ["prod", "staging", "qa"]
}

resource "aws_s3_object" "workspace_file" {
  for_each = toset(local.workspaces)
  bucket   = aws_s3_bucket.terraform_backend.id
  key      = "${each.key}-test.txt"
  content  = "Hello from ${each.key}"
  force_destroy = true
}

# DynamoDB tables for locks
resource "aws_dynamodb_table" "terraform_lock" {
  for_each = toset(local.workspaces)
  name         = "terraform-locks-${each.key}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Environment = each.key
  }
}
