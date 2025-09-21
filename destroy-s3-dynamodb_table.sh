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

# Get S3 bucket name from Terraform output
BUCKET_NAME=$(terraform output -raw s3_bucket_name || true)

if [ -n "$BUCKET_NAME" ]; then
    echo "🗑️ Step 2: Emptying bucket $BUCKET_NAME (all objects + versions)..."

    # Delete all object versions (if versioning enabled)
    aws s3api list-object-versions --bucket "$BUCKET_NAME" --query 'Versions[].{Key:Key,VersionId:VersionId}' --output json | \
    jq -c '.[]?' | while read obj; do
        KEY=$(echo $obj | jq -r '.Key')
        VERSION=$(echo $obj | jq -r '.VersionId')
        aws s3api delete-object --bucket "$BUCKET_NAME" --key "$KEY" --version-id "$VERSION"
    done

    # Delete all delete markers
    aws s3api list-object-versions --bucket "$BUCKET_NAME" --query 'DeleteMarkers[].{Key:Key,VersionId:VersionId}' --output json | \
    jq -c '.[]?' | while read obj; do
        KEY=$(echo $obj | jq -r '.Key')
        VERSION=$(echo $obj | jq -r '.VersionId')
        aws s3api delete-object --bucket "$BUCKET_NAME" --key "$KEY" --version-id "$VERSION"
    done

    echo "✅ Bucket $BUCKET_NAME emptied"
fi

echo "🔹 Step 3: Destroy all resources (S3 + DynamoDB) via Terraform..."
terraform destroy -var-file="$VAR_FILE" -auto-approve

echo "✅ All resources destroyed successfully!"
