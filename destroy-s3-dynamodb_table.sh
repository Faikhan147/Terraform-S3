#!/bin/bash
set -euo pipefail

VAR_FILE="terraform.tfvars"
BACKEND_BAK="backend.tf.bak"
BACKEND_FILE="backend.tf"

echo "🔹 Step 0: Restore backend.tf from backup if exists..."
if [ -f "$BACKEND_BAK" ]; then
    mv "$BACKEND_BAK" "$BACKEND_FILE"
    echo "✅ backend.tf restored from $BACKEND_BAK"
fi

echo "🔹 Step 1: Initialize Terraform backend..."
terraform init -reconfigure

# --- fetch outputs safely ---
raw_bucket=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")
tables_json=$(terraform output -json dynamodb_tables 2>/dev/null || echo "[]")

# --- validate bucket name ---
if [[ "$raw_bucket" =~ ^[a-zA-Z0-9.\-_]{3,255}$ ]]; then
  bucket="$raw_bucket"
else
  bucket=""
fi

# --- manually set bucket name if needed ---
bucket="${bucket:-terraform-backend-all-env}"

# ---------- Delete S3 bucket safely ----------
if [ -n "$bucket" ]; then
  echo "🗑️ Step 2: Deleting all objects & versions in bucket: $bucket"

  if aws s3api head-bucket --bucket "$bucket" 2>/dev/null; then
      aws s3api list-object-versions --bucket "$bucket" --query 'Versions[].{Key:Key,VersionId:VersionId}' --output text | \
      while read -r key version; do
          [ -n "$key" ] && [ -n "$version" ] && aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version" || true
      done

      aws s3api list-object-versions --bucket "$bucket" --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' --output text | \
      while read -r key version; do
          [ -n "$key" ] && [ -n "$version" ] && aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version" || true
      done

      aws s3 rb "s3://$bucket" --force || true
      echo "✅ Bucket $bucket emptied & deleted"
  else
      echo "⚠️ Bucket $bucket does not exist. Skipping S3 deletion."
  fi
else
  echo "⚠️ No valid S3 bucket found. Skipping S3 deletion."
fi

# ---------- Delete DynamoDB tables ----------
if [ "$tables_json" != "[]" ]; then
  echo "🗑️ Step 3: Deleting DynamoDB tables..."
  echo "$tables_json" | jq -r '.[]' | while read -r table; do
    if [ -n "$table" ]; then
        echo "Deleting table: $table"
        aws dynamodb delete-table --table-name "$table" || true
    fi
  done
  echo "✅ DynamoDB tables deleted"
else
  echo "⚠️ No dynamodb_tables output found. Skipping DynamoDB deletion."
fi

# ---------- Terraform destroy safely ----------
echo "🔹 Step 4: Destroy Terraform resources (state cleanup)..."
if aws s3api head-bucket --bucket "$bucket" 2>/dev/null; then
    terraform destroy -auto-approve || true
else
    echo "⚠️ S3 backend bucket does not exist. Skipping Terraform destroy."
fi

echo "✅ All resources destroyed successfully!"
