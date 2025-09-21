# GLOBAL RESOURCES
# -------------------------
resource "aws_s3_bucket" "terraform_backend" {
  bucket = "terraform-backend-all-env"
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

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
# WORKSPACE-SPECIFIC RESOURCES
# -------------------------
resource "aws_s3_bucket_object" "workspace_file" {
  bucket  = aws_s3_bucket.terraform_backend.id
  key     = "${terraform.workspace}-test.txt"
  content = "Hello from ${terraform.workspace}"
}
