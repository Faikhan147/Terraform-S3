output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_backend.id
}

output "dynamodb_table_names" {
  value = [for t in aws_dynamodb_table.terraform_lock : t.name]
}
