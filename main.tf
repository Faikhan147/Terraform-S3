# S3 Bucket (Global)
# -------------------------
resource "aws_s3_bucket" "terraform_backend" {
  bucket = "terraform-backend-all-env"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

# -------------------------
# DynamoDB Tables (Global)
# -------------------------
resource "aws_dynamodb_table" "terraform_lock" {
  for_each     = toset(["prod", "staging", "qa"])
  name         = "terraform-locks-${each.key}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# -------------------------
# Workspace-specific test file
# -------------------------
resource "aws_s3_bucket_object" "workspace_file" {
  for_each = toset(["prod", "staging", "qa"])
  bucket   = aws_s3_bucket.terraform_backend.id
  key      = "${each.key}-test.txt"
  content  = "Hello from ${each.key}"
}
