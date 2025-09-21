variable "region" {
  type        = string
  description = "AWS region"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name"
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN for S3 encryption"
}

variable "dynamodb_tables" {
  type        = list(string)
  description = "List of DynamoDB table names for state locking"
}
