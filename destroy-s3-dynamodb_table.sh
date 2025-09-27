#!/bin/bash
set -euo pipefail

VAR_FILE="terraform.tfvars"
BACKEND_BAK="backend.tf.bak"
BACKEND_FILE="backend.tf"
REGION="ap-south-1"   # yahan apne tables/bucket ka region set karo

echo "🔹 Step 0: Restore backend.tf from backup if exists..."
if [ -f "$BACKEND_BAK" ]; then
    mv "$BACKEND_BAK" "$BACKEND_FILE"
    echo "✅ backend.tf restored from $BACKEND_BAK"
fi

echo "🔹 Step 1: Initialize Terraform backend..."
terraform init -reconfigure

# --- fetch outputs safely ---
raw_bucket=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")
bucket="${raw_bucket:-terraform-backend-all-envs}"

# ---------- Delete S3 bucket safely ----------
echo "🗑️ Step 2: Deleting all objects & versions in bucket: $bucket"
if aws s3api head-bucket --bucket "$bucket" --region $REGION 2>/dev/null; then
    # Delete all objects and versions
    aws s3api list-object-versions --bucket "$bucket" --region $REGION --query 'Versions[].{Key:Key,VersionId:VersionId}' --output text | \
    while read -r key version; do
        [ -n "$key" ] && [ -n "$version" ] && aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version" --region $REGION
    done

    aws s3api list-object-versions --bucket "$bucket" --region $REGION --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' --output text | \
    while read -r key version; do
        [ -n "$key" ] && [ -n "$version" ] && aws s3api delete-object --bucket "$bucket" --key "$key" --version-id "$version" --region $REGION
    done

    aws s3 rb "s3://$bucket" --force --region $REGION
    echo "✅ Bucket $bucket emptied & deleted"
else
    echo "⚠️ Bucket $bucket does not exist. Skipping S3 deletion."
fi

# ---------- Delete DynamoDB tables ----------
tables=("terraform-locks-prod" "terraform-locks-qa" "terraform-locks-staging" "terraform-locks-values-prod" "terraform-locks-values-qa" "terraform-locks-values-staging")

echo "🗑️ Step 3: Deleting DynamoDB tables..."
for table in "${tables[@]}"; do
    if aws dynamodb describe-table --table-name "$table" --region $REGION &>/dev/null; then
        echo "Deleting table: $table"
        aws dynamodb delete-table --table-name "$table" --region $REGION
        # Wait for table to be fully deleted
        aws dynamodb wait table-not-exists --table-name "$table" --region $REGION
        echo "✅ Table $table deleted"
    else
        echo "⚠️ Table $table does not exist or wrong region. Skipping."
    fi
done

# ---------- Terraform destroy safely ----------
echo "🔹 Step 4: Destroy Terraform resources (state cleanup)..."
if aws s3api head-bucket --bucket "$bucket" --region $REGION 2>/dev/null; then
    terraform destroy -auto-approve
else
    echo "⚠️ S3 backend bucket does not exist. Skipping Terraform destroy."
fi

echo "✅ All resources destroyed successfully!"
