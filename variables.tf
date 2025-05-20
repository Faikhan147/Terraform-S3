variable "region" {
  description = "AWS region for backend resources"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name for Terraform remote backend"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS Key ARN for S3 encryption"
  type        = string
}
