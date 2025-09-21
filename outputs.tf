output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_backend.id
}

output "dynamodb_table_names" {
  value = [for table in aws_dynamodb_table.terraform_lock : table.id]
}
