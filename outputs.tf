# Safe output for terraform_backend S3 bucket
output "s3_bucket_name" {
  value = length(aws_s3_bucket.terraform_backend) > 0 ? aws_s3_bucket.terraform_backend[0].id : "No bucket in this workspace"
}

# DynamoDB lock tables output (already working)
output "dynamodb_table_names" {
  value = [for table in aws_dynamodb_table.terraform_lock : table.name]
}
