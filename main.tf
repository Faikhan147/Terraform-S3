# Private S3 bucket
resource "aws_s3_bucket" "private_bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"

  versioning { enabled = true }

  tags = {
    Name        = var.s3_bucket_name
    Environment = "prod"
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

  attribute { name = "id"; type = "S" }

  tags = { Environment = "prod" }
}
