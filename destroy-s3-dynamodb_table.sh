#!/bin/bash
set -euo pipefail

VAR_FILE="terraform.tfvars"
BACKEND_FILE="backend.tf"
TMP_BACKEND_FILE="backend.tf.bak"
REGION="us-east-1"

# Step 0: Temporarily disable backend
if [ -f "$BACKEND_FILE" ]; then
  mv "$BACKEND_FILE" "$TMP_BACKEND_FILE"
  echo "✅ backend.tf renamed to $TMP_BACKEND_FILE"
fi

# Step 0.5: Rename old state so Terraform doesn't try S3
mv terraform.tfstate terraform.tfstate.bak 2>/dev/null || true
mv terraform.tfstate.backup terraform.tfstate.backup.bak 2>/dev/null || true

echo "🔹 Step 1: Init Terraform locally (no backend)"
terraform init -backend=false

# Fetch outputs
raw_bucket=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")
bucket="${raw_bucket:-terraform-backend-all-envs}"

# Delete S3 bucket safely
if aws s3api head-bucket --bucket "$bucket" --region "$REGION" 2>/dev/null; then
  echo "🗑️ Deleting bucket $bucket"
  aws s3 rm s3://"$bucket" --recursive --region "$REGION" || true
  aws s3api delete-bucket --bucket "$bucket" --region "$REGION" || true
else
  echo "⚠️ Bucket $bucket not found, skipping."
fi

echo "✅ Cleanup completed"
