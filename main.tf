# Private S3 bucket
resource "aws_s3_bucket" "private_bucket" {
  bucket = var.s3_bucket_name

  acl = "private"   # Explicitly private

  tags = {
    Name        = var.s3_bucket_name
    Environment = "prod"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "private_bucket_block" {
  bucket = aws_s3_bucket.private_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "private_bucket_versioning" {
  bucket = aws_s3_bucket.private_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# DynamoDB tables
resource "aws_dynamodb_table" "tables" {
  for_each = toset(var.dynamodb_tables)

  name           = each.key
  billing_mode   = "PROVISIONED"
  read_capacity  = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "prod"
  }
}
