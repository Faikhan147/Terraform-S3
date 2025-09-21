#!/bin/bash
set -e

ENV=$1

if [[ -z "$ENV" ]]; then
  echo "❌ Please provide environment: prod | staging | qa"
  exit 1
fi

# ------------------------
# Initialize Terraform
# ------------------------
echo "🌐 Initializing Terraform for $ENV..."
terraform init -backend-config="backend-${ENV}.hcl"

# ------------------------
# Create global resources only once (default workspace)
# ------------------------
echo "🚀 Applying Global Resources..."
terraform workspace select default >/dev/null 2>&1 || terraform workspace new default
terraform plan -target=aws_s3_bucket.terraform_backend -target=aws_dynamodb_table.terraform_lock -out=tfplan_global.out >/dev/null
terraform apply tfplan_global.out -auto-approve >/dev/null || echo "✅ Global resources already exist, skipping..."

# ------------------------
# Apply workspace-specific resources
# ------------------------
echo "🌐 Deploying environment-specific resources for: $ENV"
terraform workspace select $ENV >/dev/null 2>&1 || terraform workspace new $ENV
terraform plan -out=tfplan_$ENV.out
terraform apply tfplan_$ENV.out -auto-approve

echo "✅ Deployment for $ENV completed!"
