output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_backend.id
  description = "Name of the S3 bucket used for backend"
}

output "dynamodb_table_names" {
  value       = [for t in aws_dynamodb_table.terraform_lock : t.name]
  description = "List of DynamoDB tables used for state locking"
}
