# DynamoDB Lock Table (per workspace)
# ------------------------------
resource "aws_dynamodb_table" "terraform_lock" {
  for_each = {
    prod    = "terraform-locks-prod"
    staging = "terraform-locks-staging"
    qa      = "terraform-locks-qa"
  }

  name         = each.value
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform Lock Table"
  }
}

# ------------------------------
# S3 Bucket (only create if workspace = prod)
# ------------------------------
resource "aws_s3_bucket" "terraform_backend" {
  count  = terraform.workspace == "prod" ? 1 : 0
  bucket = "terraform-backend-all-env"
  force_destroy = true

  tags = {
    Name = "Terraform Backend Bucket"
  }
}

# ------------------------------
# S3 Public Access Block
# ------------------------------
resource "aws_s3_bucket_public_access_block" "block_public_access" {
  count  = terraform.workspace == "prod" ? 1 : 0
  bucket = aws_s3_bucket.terraform_backend[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------
# S3 Encryption
# ------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  count  = terraform.workspace == "prod" ? 1 : 0
  bucket = aws_s3_bucket.terraform_backend[0].id

  rule {
    bucket_key_enabled = true

    apply_server_side_encryption_by_default {
      kms_master_key_id = "arn:aws:kms:ap-south-1:923884399206:alias/aws/s3"
      sse_algorithm     = "aws:kms"
    }
  }
}

# ------------------------------
# S3 Versioning
# ------------------------------
resource "aws_s3_bucket_versioning" "versioning" {
  count  = terraform.workspace == "prod" ? 1 : 0
  bucket = aws_s3_bucket.terraform_backend[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# ------------------------------
# Outputs
# ------------------------------
output "dynamodb_table_names" {
  value = [for k, t in aws_dynamodb_table.terraform_lock : t.name if k == terraform.workspace]
}

output "s3_bucket_name" {
  value = terraform.workspace == "prod" ? aws_s3_bucket.terraform_backend[0].bucket : "terraform-backend-all-env"
}
