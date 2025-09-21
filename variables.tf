variable "region" {
  default = "ap-south-1"
}

variable "s3_bucket_name" {
  description = "Private S3 bucket name"
  type        = string
}

variable "dynamodb_tables" {
  description = "List of DynamoDB table names for state locking"
  type        = list(string)
}

variable "dynamodb_read_capacity" {
  default = 5
}

variable "dynamodb_write_capacity" {
  default = 5
}
