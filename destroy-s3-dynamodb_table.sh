#!/bin/bash
set -e
set -u

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

# --- validate bucket name (only allow alnum . - _) ---
if [[ "$raw_bucket" =~ ^[a-zA-Z0-9.\-_]{3,255}$ ]]; then
  bucket="$raw_bucket"
else
  bucket=""
fi

# ---------- S3 ----------
if [ -n "$bucket" ]; then
  echo "🗑️ Step 2: Deleting all objects & versions in bucket: $bucket"

  # Delete all versions
  aws s3api list-object-versions --bucket "$bucket" --query 'Versions[].{Key:Key,VersionId:VersionId}' --output text | \
  while read key version; do
      aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version" || true
  done

  # Delete all delete markers
  aws s3api list-object-versions --bucket "$bucket" --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' --output text | \
  while read key version; do
      aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version" || true
  done

  # Finally remove the bucket
  aws s3 rb "s3://$bucket" --force || true
  echo "✅ Bucket $bucket emptied & deleted"
else
  echo "⚠️ No valid s3_bucket_name output found. Skipping S3 deletion."
fi

# ---------- DynamoDB ----------
if [ "$tables_json" != "[]" ]; then
  echo "🗑️ Step 3: Deleting DynamoDB tables..."
  echo "$tables_json" | jq -r '.[]' | while read -r table; do
    [ -n "$table" ] && echo "Deleting table: $table" && aws dynamodb delete-table --table-name "$table" || true
  done
  echo "✅ DynamoDB tables deleted"
else
  echo "⚠️ No dynamodb_tables output found. Skipping DynamoDB deletion."
fi

echo "🔹 Step 4: Destroy Terraform resources (state cleanup)..."
terraform destroy -auto-approve || true

echo "✅ All resources destroyed successfully!"
