output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_backend[0].id
  description = "Terraform backend S3 bucket name"
}

output "dynamodb_table_names" {
  value = [for t in aws_dynamodb_table.terraform_lock : t.name]
  description = "Terraform lock DynamoDB table names"
}
