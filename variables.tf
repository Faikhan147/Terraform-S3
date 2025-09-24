variable "region" {
  description = "AWS region name"
  type        = string
}

variable "s3_bucket_name" {
  description = "Private S3 bucket name"
  type        = string
}

variable "dynamodb_tables" {
  description = "List of DynamoDB table names for state locking"
  type        = list(string)
}
