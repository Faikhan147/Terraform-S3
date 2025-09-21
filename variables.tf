variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "S3 bucket name for Terraform backend"
  type        = string
  default     = "terraform-backend-all-env"
}

variable "dynamodb_tables" {
  description = "List of DynamoDB lock tables"
  type        = list(string)
  default     = [
    "terraform-locks-prod",
    "terraform-locks-stage",
    "terraform-locks-qa"
  ]
}

variable "kms_key_arn" {
  description = "KMS Key ARN for S3 encryption"
  type        = string
  default     = "arn:aws:kms:ap-south-1:923884399206:alias/aws/s3"
}
