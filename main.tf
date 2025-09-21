# Private S3 bucket
resource "aws_s3_bucket" "private_bucket" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = var.s3_bucket_name
    Environment = "prod"
  }
}

# Versioning as separate resource
resource "aws_s3_bucket_versioning" "private_bucket_versioning" {
  bucket = aws_s3_bucket.private_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Set ACL separately to avoid deprecation warning
resource "aws_s3_bucket_acl" "private_bucket_acl" {
  bucket = aws_s3_bucket.private_bucket.id
  acl    = "private"
}

# DynamoDB tables
resource "aws_dynamodb_table" "tables" {
  for_each = toset(var.dynamodb_tables)

  name           = each.value
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
