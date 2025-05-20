output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_backend.id
  description = "Name of the S3 bucket used for backend"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_lock.name
  description = "DynamoDB table used for state locking"
}
