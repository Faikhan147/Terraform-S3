#!/bin/bash
set -e

# -------------------------
# Argument validation
# -------------------------
ENV=$1

if [ -z "$ENV" ]; then
  echo "❌ Please provide environment: prod | staging | qa"
  exit 1
fi

echo "🌐 Initializing Terraform for $ENV..."
terraform init -backend-config="backend-${ENV}.hcl"

# -------------------------
# Apply global resources only once (S3 + DynamoDB)
# -------------------------
echo "🚀 Applying Global Resources (S3 + DynamoDB)..."
# Default workspace for global resources
terraform workspace select default >/dev/null 2>&1 || terraform workspace new default

# Check if global resources already exist in state
S3_EXISTS=$(terraform state list | grep aws_s3_bucket.terraform_backend || true)
DDB_EXISTS=$(terraform state list | grep aws_dynamodb_table.terraform_lock || true)

if [ -z "$S3_EXISTS" ] || [ -z "$DDB_EXISTS" ]; then
  terraform apply -target=aws_s3_bucket.terraform_backend \
                  -target=aws_dynamodb_table.terraform_lock \
                  -auto-approve
else
  echo "✅ Global resources already applied, skipping..."
fi

# -------------------------
# Apply workspace-specific resources
# -------------------------
echo "🌐 Deploying environment: $ENV"
terraform workspace select $ENV >/dev/null 2>&1 || terraform workspace new $ENV

# Plan and apply workspace-specific resources
terraform plan -out=tfplan_$ENV.out
terraform apply tfplan_$ENV.out

echo "✅ Deployment for $ENV completed!"
