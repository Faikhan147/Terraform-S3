# ===== S3 Backend Bucket =====
resource "aws_s3_bucket" "terraform_backend" {
  count = terraform.workspace == "prod" ? 1 : 0  # Only create for prod

  bucket = "terraform-backend-all-env"
  force_destroy = true

  tags = {
    Name = "Terraform Backend Bucket"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = "arn:aws:kms:ap-south-1:923884399206:alias/aws/s3"
      }
      bucket_key_enabled = true
    }
  }

  versioning {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  count = terraform.workspace == "prod" ? 1 : 0

  bucket = aws_s3_bucket.terraform_backend[0].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ===== DynamoDB Lock Table =====
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-locks-${terraform.workspace}"
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
