#!/bin/bash
set -e

# Check if environment argument is provided
if [ -z "$1" ]; then
  echo "❌ Please provide environment: prod | staging | qa"
  exit 1
fi

ENV=$1
BACKEND_FILE="backend-${ENV}.hcl"

# Terraform init with backend config
echo "🌐 Initializing Terraform for $ENV..."
terraform init -backend-config="$BACKEND_FILE"

# Apply global resources only once (default workspace)
echo "🚀 Applying Global Resources..."
terraform workspace select default >/dev/null 2>&1 || terraform workspace new default
terraform apply -target=aws_s3_bucket.terraform_backend -target=aws_dynamodb_table.terraform_lock -auto-approve

# Apply workspace-specific resources
echo "🌐 Deploying environment: $ENV"
terraform workspace select "$ENV" >/dev/null 2>&1 || terraform workspace new "$ENV"

terraform plan -out=tfplan_"$ENV".out
terraform apply tfplan_"$ENV".out -auto-approve

echo "✅ Deployment for $ENV completed!"
