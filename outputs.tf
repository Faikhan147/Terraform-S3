output "s3_bucket_name" {
  description = "The name of the S3 bucket used for Terraform state."
  value       = aws_s3_bucket.terraform_backend[0].id
}

output "dynamodb_table_names" {
  description = "List of DynamoDB tables used for Terraform state locking."
  value       = [for table in aws_dynamodb_table.terraform_lock : table.id]
}
