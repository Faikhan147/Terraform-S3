# --- S3 Bucket (Terraform backend) ---
resource "aws_s3_bucket" "terraform_backend" {
  bucket = "terraform-backend-all-env"

  # ACL remove kar diya
  # acl = "private"   <-- REMOVE THIS
  force_destroy = true
}

# Optional: enable versioning via separate resource
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_backend.id
  versioning_configuration {
    status = "Enabled"
  }
}

# --- DynamoDB tables for locks ---
variable "envs" {
  default = ["prod", "qa", "staging"]
}

resource "aws_dynamodb_table" "terraform_lock" {
  for_each     = toset(var.envs)
  name         = "terraform-locks-${each.key}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
