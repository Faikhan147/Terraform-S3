output "s3_bucket_name" {
  value = aws_s3_bucket.private_bucket.id
}

output "dynamodb_tables" {
  value = [for t in aws_dynamodb_table.tables : t.name]
}
