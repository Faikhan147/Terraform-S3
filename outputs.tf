output "dynamodb_table_names" {
  value = [for k, t in aws_dynamodb_table.terraform_lock : t.name if k == terraform.workspace]
}

output "s3_bucket_name" {
  value = terraform.workspace == "prod" ? aws_s3_bucket.terraform_backend[0].bucket : "terraform-backend-all-env"
