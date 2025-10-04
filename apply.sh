#!/bin/bash
set -e
set -u

VAR_FILE="terraform.tfvars"
BACKEND_FILE="backend.tf"
TMP_BACKEND_FILE="backend.tf.bak"

echo " Temporarily rename backend.tf to avoid S3 backend errors..."
if [ -f "$BACKEND_FILE" ]; then
    mv "$BACKEND_FILE" "$TMP_BACKEND_FILE"
    echo "✅ backend.tf renamed to $TMP_BACKEND_FILE"
fi

echo " Apply S3 bucket and DynamoDB tables locally first (local backend)..."
terraform init -backend=false
terraform apply -var-file="$VAR_FILE"

echo " Restore backend.tf and initialize S3 backend..."
if [ -f "$TMP_BACKEND_FILE" ]; then
    mv "$TMP_BACKEND_FILE" "$BACKEND_FILE"
    echo "✅ backend.tf restored"
fi

terraform init -reconfigure

echo " Migrate state to backend (optional)..."
terraform apply -var-file="$VAR_FILE"

echo "✅ Deployment completed successfully!"
