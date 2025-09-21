#!/bin/bash
set -e

# Terraform init with backend config
echo "🌐 Initializing Terraform..."
terraform init -backend-config="backend-${1}.hcl"

# Create global resources only once (default workspace)
echo "🚀 Applying Global Resources..."
terraform workspace select default || terraform workspace new default
terraform apply -target=aws_s3_bucket.terraform_backend -target=aws_dynamodb_table.terraform_lock -auto-approve

# Apply workspace-specific resources
echo "🌐 Deploying environment: $1"
terraform workspace select $1 || terraform workspace new $1
terraform plan -out=tfplan_$1.out
terraform apply tfplan_$1.out

echo "✅ Deployment for $1 completed!"
